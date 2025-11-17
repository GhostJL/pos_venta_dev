import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/router.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/presentation/pages/onboarding/onboarding_layout.dart';
import 'package:myapp/presentation/providers/onboarding_state.dart';
import 'package:myapp/presentation/providers/transaction_provider.dart';

class SetAccessKeyPage extends ConsumerStatefulWidget {
  const SetAccessKeyPage({super.key});

  @override
  ConsumerState<SetAccessKeyPage> createState() => _SetAccessKeyPageState();
}

class _SetAccessKeyPageState extends ConsumerState<SetAccessKeyPage> {
  final _formKey = GlobalKey<FormState>();
  final _accessKeyController = TextEditingController(text: '123');
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    _accessKeyController.dispose();
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
          content: Text(
            'Faltan datos del administrador. Por favor, reinicia la configuración.',
          ),
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
            content: Text(
              '¡Configuración completa! Ahora puedes iniciar sesión.',
            ),
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
    return OnboardingLayout(
      title: 'Paso Final',
      subtitle:
          'Crea una clave de acceso compartida para desbloquear la aplicación.',
      currentStep: 3,
      totalSteps: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.primary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Expanded(
                        child: Text(
                          'Esta clave será usada para acceder a la aplicación. Por defecto es "123".',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                TextFormField(
                  controller: _accessKeyController,
                  obscureText: _isObscured,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Clave de Acceso',
                    hintText: '123',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _isObscured = !_isObscured),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La clave es obligatoria';
                    }
                    if (value.length < 3) {
                      return 'Debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isSmallScreen ? 32 : 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _completeSetup,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Completar Configuración'),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                TextButton(
                  onPressed: () => context.go('/add-cashiers'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                  ),
                  child: const Text('Volver a Miembros del Equipo'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
