import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:test_app/logger_service.dart';
import 'package:test_app/wallet_connect_const.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

/// https://docs.walletconnect.com/api/auth/dapp-usage#request-authentication
/// https://github.com/WalletConnect/Web3ModalFlutter/issues/122
final class AuthModalSign {
  ///
  static Web3App? _web3app;

  ///
  static W3MService? _w3mService;

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
  }

  ///
  static Future<bool> authorize(BuildContext context) async {
    await dispose(); // TODO(Alex): is it necessary?
    await prepare();
    try {
      await _w3mService!.openModal(context);
      logInfo(info: 'Modal closed, connection = ${_w3mService!.isConnected}');
      if (!_w3mService!.isConnected) {
        logInfo(info: 'Connection cancelled');
        return false;
      }

      await Future<void>.delayed(const Duration(seconds: 5));

      _w3mService!.launchConnectedWallet();

      final String? signedMessage = await _web3app!.request(
        chainId: 'eip155:1',
        topic: _w3mService!.session!.topic ?? '',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: ['Test sign', _w3mService!.session!.address],
        ),
      ) as String?;

      if (signedMessage == null) {
        logInfo(info: 'Authorization cancelled');
        return false;
      }

      logInfo(info: 'Authorization succeed');
      logInfo(info: 'Address ${_w3mService!.session!.address}');
      logInfo(info: 'signature $signedMessage');
      return true;
    } catch (error) {
      logError(error: error.toString());
      return false;
    }
  }
}
