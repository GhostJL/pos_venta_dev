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

  static int _cajeroCounter = 1;

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'cajero$_cajeroCounter';
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
      id: DateTime.now().millisecondsSinceEpoch,
      username: _usernameController.text,
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

    _cajeroCounter++;

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Nuevo Cajero')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Nombre de usuario', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce un nombre de usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce un apellido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submit,
                  child: const Text('Guardar Cajero'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
