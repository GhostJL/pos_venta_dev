
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';

class AddCashierFormPage extends ConsumerStatefulWidget {
  const AddCashierFormPage({super.key});

  @override
  ConsumerState<AddCashierFormPage> createState() => _AddCashierFormPageState();
}

class _AddCashierFormPageState extends ConsumerState<AddCashierFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Static counter to ensure unique default usernames
  static int _cashierCounter = 1;

  @override
  void initState() {
    super.initState();
    // Pre-fill username to make it easier for the admin
    _usernameController.text = 'cashier$_cashierCounter';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary unique ID
      username: _usernameController.text,
      // The password will be handled by the notifier and database helper.
      // We pass the plain text password to the state.
      passwordHash: _passwordController.text, 
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: "",
      role: UserRole.cashier,
      isActive: true,
      onboardingCompleted: false, 
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(onboardingNotifierProvider.notifier).addCashier(newUser);
    
    _cashierCounter++;

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Cashier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Cashier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

