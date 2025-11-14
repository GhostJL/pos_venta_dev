
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';

class OpenSessionScreen extends ConsumerStatefulWidget {
  const OpenSessionScreen({super.key});

  @override
  ConsumerState<OpenSessionScreen> createState() => _OpenSessionScreenState();
}

class _OpenSessionScreenState extends ConsumerState<OpenSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _openingBalanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final cashSessionNotifier = ref.read(cashSessionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Cash Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _openingBalanceController,
                decoration: const InputDecoration(
                  labelText: 'Opening Balance',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the opening balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final openingBalance = int.parse(_openingBalanceController.text) * 100; // Convert to cents
                    final userId = authState?.id;
                    if (userId != null) {
                      // For now, we'll use a hardcoded warehouseId
                      cashSessionNotifier.openSession(1, userId, openingBalance);
                    }
                  }
                },
                child: const Text('Open Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
