import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';

class CashierFormPage extends ConsumerStatefulWidget {
  final User? cashier;

  const CashierFormPage({super.key, this.cashier});

  @override
  ConsumerState<CashierFormPage> createState() => _CashierFormPageState();
}

class _CashierFormPageState extends ConsumerState<CashierFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  bool _isActive = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.cashier?.username ?? '',
    );
    _passwordController = TextEditingController(); // Password empty on edit
    _firstNameController = TextEditingController(
      text: widget.cashier?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.cashier?.lastName ?? '',
    );
    _emailController = TextEditingController(text: widget.cashier?.email ?? '');
    _isActive = widget.cashier?.isActive ?? true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cashier != null;
    final controllerState = ref.watch(cashierControllerProvider);

    ref.listen(cashierControllerProvider, (previous, next) {
      if (next is AsyncData && !next.isLoading) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Cajero actualizado' : 'Cajero creado'),
          ),
        );
      } else if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Cajero' : 'Nuevo Cajero')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!isEditing) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Opcional)',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activo'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controllerState.isLoading ? null : _submit,
                  child: controllerState.isLoading
                      ? const CircularProgressIndicator()
                      : Text(isEditing ? 'Actualizar' : 'Crear'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: widget.cashier?.id,
        username: _usernameController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        role: UserRole.cajero,
        isActive: _isActive,
        createdAt: widget.cashier?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.cashier != null) {
        ref.read(cashierControllerProvider.notifier).updateCashier(user);
      } else {
        ref
            .read(cashierControllerProvider.notifier)
            .createCashier(user, _passwordController.text);
      }
    }
  }
}
