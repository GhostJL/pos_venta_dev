import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';

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
  final _lastNameController = TextEditingController(text: 'Usuario');
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

    final adminUser = User(
      id: 0, // Será autogenerado por la base de datos
      username: _usernameController.text,
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      role: UserRole.admin,
      isActive: true,
      onboardingCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Actualizar el estado de onboarding con el usuario admin y su contraseña
    ref
        .read(onboardingNotifierProvider.notifier)
        .setAdmin(adminUser, _passwordController.text);

    context.push('/add-cashiers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Cuenta de Administrador')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '¡Bienvenido! Vamos a crear tu cuenta de administrador.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'El nombre de usuario es obligatorio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'La contraseña es obligatoria';
                    if (value.length < 8)
                      return 'La contraseña debe tener al menos 8 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'El apellido es obligatorio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'El correo electrónico es obligatorio' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submit,
                  child: const Text('Guardar y Continuar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
