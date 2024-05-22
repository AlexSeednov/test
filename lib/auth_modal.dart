import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:test_app/logger_service.dart';
import 'package:test_app/wallet_connect_const.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

/// https://docs.walletconnect.com/api/auth/dapp-usage#request-authentication
/// https://github.com/WalletConnect/Web3ModalFlutter/issues/122
final class AuthModal {
  ///
  static Web3App? _web3app;

  ///
  static W3MService? _w3mService;

  ///
  static AuthRequestResponse? _authorizationRequest;

  ///
  static Future<void> prepare() async {
    _web3app = await Web3App.createInstance(
      projectId: walletConnectProjectId,
      metadata: walletConnectMetadata,
    );

    /// Only Ethereum or Polygon as available chains
    W3MChainPresets.chains.removeWhere(
      (String key, W3MChainInfo value) =>
          value.chainName != 'Ethereum' && value.chainName != 'Polygon',
    );
    _w3mService = W3MService(
      web3App: _web3app,
      projectId: walletConnectProjectId,
      metadata: walletConnectMetadata,
      includedWalletIds: walletConnectIncluded,
      /*requiredNamespaces: {
        'eip155': const W3MNamespace(
          chains: ['eip155:1'],
          methods: [
            MethodConstants.WC_AUTH_REQUEST,
            "personal_sign",
          ],
          events: [
            "chainChanged",
            "accountsChanged",
            "message",
            "disconnect",
            "connect",
          ],
        ),
      },*/
      //optionalNamespaces: {},
    );

    await _w3mService!.init();
  }

  ///
  static Future<void> dispose() async {
    _web3app = null;
    if (_w3mService?.isConnected ?? false) {
      await _w3mService!.disconnect();
    }
    _w3mService = null;

    _authorizationRequest = null;
  }

  ///
  static Future<bool> authorize(BuildContext context) async {
    await dispose(); // TODO(Alex): is it necessary?
    await prepare();
    try {
      await _w3mService!.openModal(context);
      logInfo(info: 'Modal closed, connection = ${_w3mService!.isConnected}');
      await Future<void>.delayed(const Duration(seconds: 5));

      _w3mService!.launchConnectedWallet();

      _authorizationRequest = await _web3app!.requestAuth(
        params: authorizationParameters('Try to auth'),
        pairingTopic: _w3mService!.session!.pairingTopic,
      );

      final AuthResponse authResponse =
          await _authorizationRequest!.completer.future;

      if (authResponse.result == null) {
        /// Some error happened
        if (authResponse.error != null) {
          /// Was an issue verifying the signature.
          final WalletConnectError error = authResponse.error!;
          logError(
            error: 'WalletConnectError: '
                '${error.message} '
                '(code: ${error.code})',
          );
        } else if (authResponse.jsonRpcError != null) {
          /// Something went wrong when signing with the wallet.
          final JsonRpcError error = authResponse.jsonRpcError!;
          logError(
            error: 'JsonRpcError: '
                '${error.message} '
                '(code: ${error.code})',
          );
        } else {
          /// Unexpected error
          logError(error: 'Unknown error on authorization flow');
        }
        return false;
      }

      /// Having a result indicates that the signature has been verified.
      /// Retrieve the wallet address from a successful response
      final String walletAddress =
          AddressUtils.getDidAddress(authResponse.result!.p.iss);

      logInfo(info: 'Authorization succeed');
      logInfo(info: 'Address $walletAddress');
      logInfo(info: 'iat ${authResponse.result!.p.iat}');
      logInfo(info: 'signature ${authResponse.result!.s.s}');
      return true;
    } catch (error) {
      logError(error: error.toString());
      return false;
    }
  }
}
