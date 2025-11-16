import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/router.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';
import 'package:myapp/presentation/providers/transaction_provider.dart';

class SetAccessKeyPage extends ConsumerStatefulWidget {
  const SetAccessKeyPage({super.key});

  @override
  ConsumerState<SetAccessKeyPage> createState() => _SetAccessKeyPageState();
}

class _SetAccessKeyPageState extends ConsumerState<SetAccessKeyPage> {
  final _formKey = GlobalKey<FormState>();
  final _accessKeyController = TextEditingController();
  final _confirmAccessKeyController = TextEditingController();
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    _accessKeyController.dispose();
    _confirmAccessKeyController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final onboardingState = ref.read(onboardingNotifierProvider);
    final finalState = onboardingState.copyWith(
      accessKey: _accessKeyController.text,
    );

    if (finalState.adminUser == null || finalState.adminPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faltan datos del administrador. Por favor, reinicia la configuración.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final dbHelper = ref.read(databaseHelperProvider);
      await dbHelper.setupInitialData(finalState);

      ref.read(onboardingNotifierProvider.notifier).reset();
      ref.invalidate(onboardingCompletedProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Configuración completa! Ya puedes iniciar sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error inesperado: $e')),
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
        title: const Text('Establecer Clave de Acceso'),
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
                  'Último Paso: Crea una Clave de Acceso',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Esta clave es un PIN compartido que todos los usuarios (administradores y cajeros) usarán para desbloquear la aplicación al iniciar. No es tu contraseña personal.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _accessKeyController,
                  obscureText: _isObscured,
                  decoration: InputDecoration(
                    labelText: 'Nueva Clave de Acceso',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isObscured = !_isObscured),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'La clave es obligatoria';
                    if (value.length < 4) return 'Debe tener al menos 4 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmAccessKeyController,
                  obscureText: _isObscured,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Clave de Acceso',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != _accessKeyController.text) return 'Las claves no coinciden';
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
                      : const Text('Completar Configuración'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
