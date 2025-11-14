
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to your new app!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Primary Button'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
          ],
        ),
      ),
    );
  }
}
