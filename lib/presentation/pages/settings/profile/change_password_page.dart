import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.removeListener(_updatePasswordStrength);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _newPasswordController.text;
    double strength = 0.0;
    if (password.isNotEmpty) {
      if (password.length >= 6) strength += 0.25;
      if (password.length >= 10) strength += 0.25;
      if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
      if (RegExp(r'[0-9!@#\$&*~]').hasMatch(password)) strength += 0.25;
    }
    setState(() {
      _passwordStrength = strength;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authRepo = ref.read(authRepositoryProvider);
        final currentUser = ref.read(authProvider).user;

        if (currentUser == null) {
          throw Exception('Usuario no autenticado');
        }

        // 1. Verify current password
        final user = await authRepo.login(
          currentUser.username,
          _currentPasswordController.text,
        );

        if (user == null) {
          setState(() {
            _errorMessage = 'La contraseña actual no es correcta.';
            _isLoading = false;
          });
          return;
        }

        // 2. Update to new password
        await authRepo.updatePassword(
          currentUser.id!,
          _newPasswordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Contraseña actualizada con éxito'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              showCloseIcon: true,
            ),
          );
          context.pop();
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Cambiar Contraseña',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Header Icon
                Text(
                  'Protege tu cuenta',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea una contraseña segura que recuerdes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_rounded,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildPasswordField(
                        controller: _currentPasswordController,
                        label: 'Contraseña Actual',
                        colorScheme: colorScheme,
                        icon: Icons.vpn_key_rounded,
                      ),
                      const SizedBox(height: 24),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'Nueva Contraseña',
                        colorScheme: colorScheme,
                        icon: Icons.lock_rounded,
                      ),
                      // Password Strength Indicator
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              color: _getStrengthColor(_passwordStrength),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getStrengthLabel(_passwordStrength),
                              style: TextStyle(
                                color: _getStrengthColor(_passwordStrength),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar Contraseña',
                        colorScheme: colorScheme,
                        icon: Icons.check_circle_outline_rounded,
                        validator: (val) {
                          if (val != _newPasswordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: colorScheme.primary,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Actualizar Contraseña',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _getStrengthLabel(double strength) {
    if (strength == 0) return '';
    if (strength <= 0.25) return 'Débil';
    if (strength <= 0.5) return 'Regular';
    if (strength <= 0.75) return 'Buena';
    return 'Excelente';
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required ColorScheme colorScheme,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator:
          validator ??
          (val) {
            if (val == null || val.isEmpty) return 'Requerido';
            if (val.length < 6) return 'Mínimo 6 caracteres';
            return null;
          },
      style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
    );
  }
}
