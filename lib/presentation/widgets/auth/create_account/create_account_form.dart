import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/create_account_provider.dart';

class CreateAccountForm extends ConsumerStatefulWidget {
  const CreateAccountForm({super.key});

  @override
  ConsumerState<CreateAccountForm> createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends ConsumerState<CreateAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _warehouseNameController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _useInventory = true;
  bool _useTax = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _warehouseNameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => _currentStep = 1);
    }
  }

  void _prevStep() {
    setState(() => _currentStep = 0);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(createAccountProvider.notifier)
        .createAccount(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          warehouseName: _warehouseNameController.text.trim(),
          useInventory: _useInventory,
          useTax: _useTax,
        );
  }

  @override
  Widget build(BuildContext context) {
    // ... existing build method ...
    final state = ref.watch(createAccountProvider);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step Indicator
            Text(
              _currentStep == 0
                  ? 'Información Personal (1/2)'
                  : 'Seguridad y Sucursal (2/2)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            if (_currentStep == 0) _buildStep1(context) else _buildStep2(),

            const SizedBox(height: 32),

            // Navigation Buttons
            Row(
              children: [
                if (_currentStep == 1)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.isLoading ? null : _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Atrás'),
                    ),
                  ),
                if (_currentStep == 1) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: state.isLoading
                        ? null
                        : (_currentStep == 0 ? _nextStep : _submit),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _currentStep == 0 ? 'Siguiente' : 'Crear Cuenta',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        return Column(
          children: [
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'El usuario es obligatorio' : null,
            ),
            const SizedBox(height: 16),
            if (isNarrow) ...[
              TextFormField(
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'El apellido es obligatorio' : null,
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'El nombre es obligatorio' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'El apellido es obligatorio' : null,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (_) => _nextStep(),
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El correo es obligatorio';
                }
                if (!value.contains('@')) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        TextFormField(
          controller: _warehouseNameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Nombre Sucursal',
            helperText: 'Se creará como sucursal principal',
            prefixIcon: Icon(Icons.store_outlined),
          ),
          validator: (value) =>
              value!.isEmpty ? 'El nombre de la sucursal es obligatorio' : null,
        ),
        const SizedBox(height: 16),

        // Settings Toggles
        SwitchListTile(
          title: const Text('Gestionar Inventario'),
          subtitle: const Text('Control de stock (recomendado: activado)'),
          value: _useInventory,
          onChanged: (value) => setState(() => _useInventory = value),
          contentPadding: EdgeInsets.zero,
        ),

        SwitchListTile(
          title: const Text('Gestionar Impuestos (IVA)'),
          subtitle: const Text(
            'Aplicar impuestos a ventas (recomendado: activado)',
          ),
          value: _useTax,
          onChanged: (value) => setState(() => _useTax = value),
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _passwordController,
          obscureText: _isPasswordObscured,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() => _isPasswordObscured = !_isPasswordObscured);
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La contraseña es obligatoria';
            }
            if (value.length < 6) {
              return 'Mínimo 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _isConfirmPasswordObscured,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Confirmar Contraseña',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(
                  () =>
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured,
                );
              },
            ),
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
      ],
    );
  }
}
