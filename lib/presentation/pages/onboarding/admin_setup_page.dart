
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';

// A new provider to store the admin password temporarily during onboarding.
// This is not best practice for production, but suffices for this flow.
// A more secure approach would use a secure storage solution.
final adminPasswordProvider = StateProvider<String?>((ref) => null);

class AdminSetupPage extends ConsumerStatefulWidget {
  const AdminSetupPage({super.key});

  @override
  ConsumerState<AdminSetupPage> createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends ConsumerState<AdminSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(text: 'admin');
  final _firstNameController = TextEditingController(text: 'Admin');
  final _lastNameController = TextEditingController(text: 'User');
  final _emailController = TextEditingController(text: 'admin@example.com');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // 1. Create the admin User object from form data
    final adminUser = User(
      id: 0, // ID will be assigned by the database later
      username: _usernameController.text,
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      role: UserRole.admin, // Set role to admin
      isActive: true,
      onboardingCompleted: false, // Will be set to true upon final transaction
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 2. Update the onboarding state with the admin data
    ref.read(onboardingNotifierProvider.notifier).setAdmin(adminUser);
    
    // 3. Store the password in the temporary provider
    ref.read(adminPasswordProvider.notifier).state = _passwordController.text;

    // 4. Navigate to the next step
    context.push('/add-cashiers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Admin Account'),
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
                  'Welcome! Let\'s create your admin account.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 4) return 'Password must be at least 4 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'First name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Last name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submit,
                  child: const Text('Save and Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
