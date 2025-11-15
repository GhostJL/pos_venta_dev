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

  // A counter to create unique usernames for cashiers easily
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary unique ID
      username: _usernameController.text,
      passwordHash: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: "",
      role: UserRole.cashier,
      isActive: true,
      onboardingCompleted: false, // Not relevant until saved
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Add the new cashier to the in-memory list
    ref.read(onboardingNotifierProvider.notifier).addCashier(newUser);
    
    // Increment the counter for the next default username
    _cashierCounter++;

    // Go back to the cashier list page
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Team Member'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Username is required' : null,
              ),
              
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController, // Added phone controller
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Password is required' : null, // Added validator
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'First Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Last Name is required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
                child: const Text('Add Member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}