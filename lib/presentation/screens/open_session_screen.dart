import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/app/theme.dart';
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.store_mall_directory_outlined,
                  size: 80,
                  color: AppTheme.primary.withAlpha(204),
                ),
                const SizedBox(height: 24),
                Text(
                  'Start a New Session',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the initial cash amount to begin your sales session.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _openingBalanceController,
                  decoration: const InputDecoration(
                    labelText: 'Opening Balance',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a balance';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    if (double.parse(value) < 0) {
                      return 'Balance cannot be negative';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final openingBalance =
                          (double.parse(_openingBalanceController.text) * 100)
                              .toInt();
                      final userId = authState?.id;
                      if (userId != null) {
                        // Hardcoded warehouseId for now
                        cashSessionNotifier.openSession(
                          1,
                          userId,
                          openingBalance,
                        );
                      }
                    }
                  },
                  child: const Text('Open Session'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
