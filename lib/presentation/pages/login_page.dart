
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';

  void _login() async {
    final pin = _pinController.text;
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Please enter your PIN');
      return;
    }

    final success = await ref.read(authProvider.notifier).login(pin);

    if (!success && mounted) {
      setState(() {
        _errorMessage = ref.read(authProvider).errorMessage ?? 'Invalid PIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Enter Your PIN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                ),
                onChanged: (_) => setState(() => _errorMessage = ''),
              ),
              const SizedBox(height: 20),
              if (authState.status == AuthStatus.loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
