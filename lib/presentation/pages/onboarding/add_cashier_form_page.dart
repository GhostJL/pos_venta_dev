import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/pages/onboarding/onboarding_layout.dart';

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

  static int _cashierCounter = 1;

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'cajero$_cashierCounter';
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
      role: UserRole.cajero,
      isActive: true,
      onboardingCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(onboardingProvider.notifier).addCashier(newUser);
    _cashierCounter++;

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: 'Añadir Nuevo Cajero',
      subtitle: 'Introduce los detalles del nuevo miembro del equipo.',
      currentStep: 2,
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
                      ? 'Por favor, introduce un nombre de usuario'
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
                    if (value == null || value.isEmpty || value.length < 8) {
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
                      value!.isEmpty ? 'Por favor, introduce un nombre' : null,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'Por favor, introduce un apellido'
                      : null,
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Guardar Cajero'),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
