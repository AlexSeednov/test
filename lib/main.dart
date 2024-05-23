import 'package:flutter/material.dart';

import 'package:test_app/auth_directly.dart';
import 'package:test_app/auth_modal.dart';
import 'package:test_app/auth_modal_sign.dart';
import 'package:test_app/auth_web3app.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ///
            const Text('Authorization directly'),

            /// On Android
            /// Endless "Connecting to MetaMask"
            ///
            /// On iOS
            /// Endless "Connecting to MetaMask"
            FilledButton(
              onPressed: () => {AuthDirectly.authorize('metamask')},
              child: const Text('Metamask directly'),
            ),

            /// On Android
            /// Working fine, but without returning to the app from wallet
            ///
            /// On iOS got error
            /// `JsonRpcError: Method Unsupported (code: 10001)`
            FilledButton(
              onPressed: () => {AuthDirectly.authorize('trust')},
              child: const Text('Trust directly'),
            ),
            const SizedBox(height: 20),

            /// On Android
            /// Trust
            /// Working fine, but without returning to the app from wallet
            /// Metamask
            /// Success connection, but endless "Connecting to MetaMask"
            /// after reopening with requestAuth
            ///
            ///
            /// On iOS
            /// Trust
            /// `JsonRpcError: Method Unsupported (code: 10001)`
            /// Metamask
            /// Success connection, but without sign functionality
            /// after reopening with requestAuth
            const Text('Authorization via modal'),
            FilledButton(
              onPressed: () => {AuthModal.authorize(context)},
              child: const Text('Auth via modal'),
            ),
            const SizedBox(height: 20),

            /// On Android
            /// Trust
            ///
            /// Metamask
            ///
            ///
            ///
            /// On iOS
            /// Trust
            ///
            /// Metamask
            ///
            const Text('Authorization by Sign via modal'),
            FilledButton(
              onPressed: () => {AuthModalSign.authorize(context)},
              child: const Text('Auth by Sign via modal'),
            ),
            const SizedBox(height: 20),

            ///
            const Text('Authorization via Web3App'),

            /// On Android not working
            /// Success connection, but without sign functionality
            /// after reopening with requestAuth
            ///
            /// On iOS not working
            /// Success connection, but without sign functionality
            /// after reopening with requestAuth
            FilledButton(
              onPressed: () => {AuthWeb3Appp.authorize('metamask')},
              child: const Text('Metamask Web3App'),
            ),

            /// On Android
            /// Working fine, but without returning to the app from wallet
            ///
            /// On iOS got error
            /// `JsonRpcError: Method Unsupported (code: 10001)`
            FilledButton(
              onPressed: () => {AuthWeb3Appp.authorize('trust')},
              child: const Text('Trust Web3App'),
            ),
          ],
        ),
      ),
    );
  }
}
