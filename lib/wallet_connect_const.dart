import 'package:web3modal_flutter/web3modal_flutter.dart';

///
const String walletConnectProjectId = 'Insert your Project ID here';

///
const PairingMetadata walletConnectMetadata = PairingMetadata(
  name: 'Test App',
  description: 'Test App',
  url: 'https://www.walletconnect.com/',
  icons: ['https://walletconnect.com/walletconnect-logo.png'],
  redirect: Redirect(
    native: 'bricktest://',
    universal: 'https://www.walletconnect.com',
  ),
);

///
final Set<String> walletConnectIncluded = {
  // MetaMask
  'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
  // Trust
  '4622a2b2d6af1c9844944291e5e7351a6aa24cd7b23099efac1b2fd875da31a0',
};

///
AuthRequestParams authorizationParameters(String? information) =>
    AuthRequestParams(
      aud: 'https://test.com/login',
      domain: 'test.com',
      chainId: 'eip155:1',
      statement: information,
    );
