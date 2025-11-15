
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/router.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/presentation/pages/onboarding/admin_setup_page.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';

class SetPinPage extends ConsumerStatefulWidget {
  const SetPinPage({super.key});

  @override
  ConsumerState<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends ConsumerState<SetPinPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. Get all data from the onboarding state providers
    final onboardingState = ref.read(onboardingNotifierProvider);
    final adminUser = onboardingState.admin;
    final cashiers = onboardingState.cashiers;
    final adminPassword = ref.read(adminPasswordProvider);
    final pin = _pinController.text;

    if (adminUser == null || adminPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin data is missing. Please restart the setup.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Execute the database transaction
      final dbHelper = DatabaseHelper();
      await dbHelper.completeOnboardingTransaction(
        admin: adminUser,
        cashiers: cashiers,
        pin: pin,
        adminPassword: adminPassword,
      );

      // 3. Reset all onboarding state
      ref.read(onboardingNotifierProvider.notifier).reset();
      ref.read(adminPasswordProvider.notifier).state = null;
      
      // 4. Invalidate the router provider to force a redirect check
      ref.invalidate(onboardingCompletedProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setup complete! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        // 5. Navigate to the login screen
        context.go('/login');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Admin Access PIN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/add-cashiers'), // Allow going back
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Final Step: Set a Security PIN',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This PIN will be used for critical admin actions.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '4-Digit PIN', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'PIN is required';
                    if (value.length != 4) return 'PIN must be exactly 4 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Confirm PIN', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value != _pinController.text) return 'PINs do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _completeSetup,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Complete Setup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
