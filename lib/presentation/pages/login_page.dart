import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_usernameController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    ref.listen<AuthState>(authProvider, (_, state) {
      if (state.status == AuthStatus.error && state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 32),

                // Form Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Por favor, introduce tu usuario'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isPasswordObscured,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _isPasswordObscured =
                                        !_isPasswordObscured,
                                  );
                                },
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Por favor, introduce tu contraseña'
                                : null,
                          ),
                          const SizedBox(height: 32),

                          // Login Button
                          ElevatedButton(
                            onPressed: auth.status == AuthStatus.loading
                                ? null
                                : () => _login(authProvider),
                            child: auth.status == AuthStatus.loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text('Iniciar Sesión'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.storefront_rounded, size: 64, color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(
          textAlign: TextAlign.center,
          'Bienvenido de Vuelta',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para gestionar tu tienda',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
