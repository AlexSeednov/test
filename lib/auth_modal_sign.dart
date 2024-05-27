import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:test_app/logger_service.dart';
import 'package:test_app/wallet_connect_const.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

/// https://docs.walletconnect.com/api/auth/dapp-usage#request-authentication
/// https://github.com/WalletConnect/Web3ModalFlutter/issues/122
final class AuthModalSign {
  ///
  static W3MService? _w3mService;

  ///
  static Future<void> prepare() async {
    /// Only Ethereum or Polygon as available chains
    W3MChainPresets.chains.removeWhere(
      (String key, W3MChainInfo value) =>
          value.chainName != 'Ethereum' && value.chainName != 'Polygon',
    );
    _w3mService = W3MService(
      projectId: walletConnectProjectId,
      metadata: walletConnectMetadata,
      includedWalletIds: walletConnectIncluded,
    );

    await _w3mService!.init();
  }

  ///
  static Future<void> dispose() async {
    if (_w3mService?.isConnected ?? false) await _w3mService!.disconnect();
    _w3mService = null;
  }

  ///
  static Future<bool> authorize(BuildContext context) async {
    await prepare();
    try {
      await _w3mService!.openModal(context);
      logInfo(info: 'Modal closed, connection = ${_w3mService!.isConnected}');
      if (!_w3mService!.isConnected) {
        logInfo(info: 'Connection cancelled');
        await dispose();
        return false;
      }

      await Future<void>.delayed(const Duration(seconds: 5));

      _w3mService!.launchConnectedWallet();

      final String? signedMessage = await _w3mService!.request(
        chainId: 'eip155:1',
        topic: _w3mService!.session!.topic ?? '',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: ['Test sign', _w3mService!.session!.address],
        ),
      ) as String?;

      if (signedMessage == null) {
        logInfo(info: 'Authorization cancelled');
        await dispose();
        return false;
      }

      if (signedMessage.startsWith('0x')) {
        logInfo(info: 'Authorization succeed');
        logInfo(info: 'Address ${_w3mService!.session!.address}');
        logInfo(info: 'signature $signedMessage');
        await dispose();
        return true;
      } else {
        /// Got error
        logInfo(info: 'Authorization failed');
        logInfo(info: 'Address ${_w3mService!.session!.address}');
        logInfo(info: 'Error $signedMessage');
        await dispose();
        return true;
      }
    } catch (error) {
      logError(error: error.toString());

      await dispose();
      return true;
    }
  }
}
