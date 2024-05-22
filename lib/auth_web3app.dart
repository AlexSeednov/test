import 'dart:async';

import 'package:test_app/logger_service.dart';
import 'package:test_app/wallet_connect_const.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

/// https://pub.dev/packages/walletconnect_flutter_v2
/// https://gist.github.com/quetool/f934b449ed0027f8b435622a2719328a
final class AuthWeb3Appp {
  ///
  static Web3App? _web3app;

  ///
  static SessionData? _sessionData;

  ///
  static Future<void> prepare() async {
    _web3app = await Web3App.createInstance(
      projectId: walletConnectProjectId,
      metadata: walletConnectMetadata,
    );

    logInfo(info: 'Web3App prepared');
  }

  ///
  static void dispose() {
    _web3app = null;
    _sessionData = null;
    logInfo(info: 'Web3App disposed');
  }

  ///
  static Future<bool> _connect(String wallet) async {
    final ConnectResponse connectResponse = await _web3app!.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          chains: ['eip155:1'],
          methods: ["personal_sign"],
          events: [
            "chainChanged",
            "accountsChanged",
          ],
        ),
      },
    );

    final uri = connectResponse.uri;
    if (uri == null) {
      logError(error: 'Uri not found');
      return false;
    }

    final String connectionLink = Uri.encodeComponent(uri.toString());

    final String link = '$wallet://wc?uri=$connectionLink';

    await launchUrlString(link, mode: LaunchMode.externalApplication);
    _sessionData = await connectResponse.session.future;

    logInfo(info: 'Web3App connected');
    return true;
  }

  ///
  static Future<bool> authorize(String wallet) async {
    await prepare();
    final bool connectionResult = await _connect(wallet);
    if (!connectionResult) return false;

    try {
      final AuthRequestResponse authRequest = await _web3app!.requestAuth(
        pairingTopic: _sessionData!.pairingTopic,
        params: authorizationParameters('Try to auth'),
      );

      /// Need to open somewhow a necessary wallet
      final String link = '$wallet://wc';

      logInfo(info: 'Link to open for authorization - $link');

      await launchUrlString(link, mode: LaunchMode.externalApplication);

      final AuthResponse authResponse = await authRequest.completer.future;

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
