import 'dart:async';

import 'package:test_app/logger_service.dart';
import 'package:test_app/wallet_connect_const.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

/// https://docs.walletconnect.com/api/auth/dapp-usage#request-authentication
final class AuthModal {
  ///
  static AuthClient? _authorizationClient;

  ///
  static AuthRequestResponse? _authorizationRequest;

  ///
  static Future<void> prepare() async {
    _authorizationClient = await AuthClient.createInstance(
      projectId: walletConnectProjectId,
      metadata: walletConnectMetadata,
    );
  }

  ///
  static void dispose() {
    _authorizationClient = null;
    _authorizationRequest = null;
  }

  ///
  static Future<bool> authorize() async {
    await prepare();
    try {
      _authorizationRequest = await _authorizationClient!.request(
        params: authorizationParameters('Try to auth'),
      );

      final String connectionLink =
          Uri.encodeComponent(_authorizationRequest!.uri.toString());

      final String link = 'trust://wc?uri=$connectionLink';
      //'https://link.trustwallet.com/wc?uri=$connectionLink';
      //'metamask://wc?uri=$connectionLink';
      //'https://metamask.app.link/wc?uri=$connectionLink';
      //'wc://wc?uri=$connectionLink';

      logInfo(info: 'Link to open for authorization - $link');

      await launchUrlString(link);

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
