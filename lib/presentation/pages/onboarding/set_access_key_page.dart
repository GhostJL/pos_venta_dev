
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/router.dart'; // Added import
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';

class SetAccessKeyPage extends ConsumerStatefulWidget {
  const SetAccessKeyPage({super.key});

  @override
  ConsumerState<SetAccessKeyPage> createState() => _SetAccessKeyPageState();
}

class _SetAccessKeyPageState extends ConsumerState<SetAccessKeyPage> {
  final _formKey = GlobalKey<FormState>();
  final _accessKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _accessKeyController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final onboardingState = ref.read(onboardingNotifierProvider);
    final finalState = onboardingState.copyWith(accessKey: _accessKeyController.text);

    if (finalState.adminUser == null || finalState.adminPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin data is missing. Please restart the setup.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.setupInitialData(finalState);

      ref.read(onboardingNotifierProvider.notifier).reset();
      ref.invalidate(onboardingCompletedProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setup complete! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
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
        title: const Text('Set Application Access Key'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/add-cashiers'),
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
                  'Final Step: Set Access Key',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This key will be required to use the application.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _accessKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Access Key',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Access key is required';
                    if (value != '123 clave de acceso') return 'Invalid access key';
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
