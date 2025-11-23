import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/pages/onboarding/onboarding_layout.dart';

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
      id: 0,
      username: _usernameController.text,
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      role: UserRole.administrador,
      isActive: true,
      onboardingCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref
        .read(onboardingProvider.notifier)
        .setAdmin(adminUser, _passwordController.text);
    context.push('/add-cashiers');
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: '¡Bienvenido!',
      subtitle: 'Vamos a crear tu cuenta de administrador.',
      currentStep: 1,
      totalSteps: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'El nombre de usuario es obligatorio'
                      : null,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contraseña es obligatoria';
                    }
                    if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'El nombre es obligatorio' : null,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'El apellido es obligatorio' : null,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty
                      ? 'El correo electrónico es obligatorio'
                      : null,
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Guardar y Continuar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
