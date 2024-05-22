import 'package:flutter/material.dart';
import 'package:test_app/auth_directly.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Test WC app'),
            FilledButton(
              onPressed: () => {
                AuthDirectly.authorize('metamask'),
              },
              child: const Text('Metamask Auth directly'),
            ),
            FilledButton(
              onPressed: () => {
                AuthDirectly.authorize('trust'),
              },
              child: const Text('Trus Auth directly'),
            ),
            FilledButton(
              onPressed: () => {},
              child: const Text('Auth via modal'),
            ),
            FilledButton(
              onPressed: () => {},
              child: const Text('Auth via Web3App'),
            ),
          ],
        ),
      ),
    );
  }
}
