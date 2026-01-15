import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';
import 'package:posventa/presentation/providers/user_provider.dart';
import 'package:posventa/presentation/widgets/users/permission_selector_widget.dart';

class UserFormPage extends ConsumerStatefulWidget {
  final User? user;

  const UserFormPage({super.key, this.user});

  @override
  ConsumerState<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends ConsumerState<UserFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  bool _isActive = true;
  bool _isPasswordVisible = false;
  UserRole _selectedRole = UserRole.cajero;
  List<int> _selectedPermissionIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController();
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _isActive = user?.isActive ?? true;
    _selectedRole = user?.role ?? UserRole.cajero;

    // Initialize permissions if editing a cashier/user with permissions logic
    // For now, new users get defaults if cashier
    if (user == null && _selectedRole != UserRole.administrador) {
      _setDefaultPermissions();
    }
  }

  void _setDefaultPermissions() {
    ref.read(allPermissionsProvider.future).then((perms) {
      if (!mounted) return;
      List<int> defaultPermissions = [];

      if (_selectedRole == UserRole.gerente) {
        // Manager gets ALL permissions
        defaultPermissions = perms.map((p) => p.id!).toList();
      } else if (_selectedRole == UserRole.espectador) {
        // Viewer gets Read-Only permissions (Inventory View, Reports View)
        defaultPermissions = perms
            .where((p) {
              return [
                PermissionConstants.inventoryView,
                PermissionConstants.reportsView,
              ].contains(p.code);
            })
            .map((p) => p.id!)
            .toList();
      } else if (_selectedRole == UserRole.cajero) {
        // Cashier gets default set
        defaultPermissions = perms
            .where((p) {
              return [
                PermissionConstants.posAccess,
                PermissionConstants.reportsView,
                PermissionConstants.customerManage,
                PermissionConstants.cashOpen,
                PermissionConstants.cashClose,
                PermissionConstants.cashMovement,
              ].contains(p.code);
            })
            .map((p) => p.id!)
            .toList();
      }

      setState(() {
        _selectedPermissionIds = defaultPermissions;
      });
    });
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
    // Watch logic to keep provider alive, even if autoDispose
    ref.watch(cashierControllerProvider);

    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información Personal'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Opcional)',
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Cuenta y Seguridad'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Usuario',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              if (!isEditing)
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
                      return 'Requerido';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (UserRole? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRole = newValue;
                      if (_selectedRole != UserRole.administrador) {
                        _setDefaultPermissions();
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Usuario Activo'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),

              if (_selectedRole != UserRole.administrador) ...[
                const SizedBox(height: 32),
                Text(
                  'Permisos de ${_selectedRole.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                PermissionSelectorWidget(
                  selectedPermissionIds: _selectedPermissionIds,
                  visiblePermissionCodes: _getVisiblePermissionsForRole(
                    _selectedRole,
                  ),
                  onChanged: (ids) {
                    setState(() {
                      _selectedPermissionIds = ids;
                    });
                  },
                ),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? 'Guardar Cambios' : 'Crear Usuario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  List<String>? _getVisiblePermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.gerente:
        // Managers see all permissions
        return null;
      case UserRole.cajero:
        return [
          PermissionConstants.posAccess,
          PermissionConstants.posDiscount,
          PermissionConstants.posRefund,
          PermissionConstants.posVoidItem,
          PermissionConstants.cashOpen,
          PermissionConstants.cashClose,
          PermissionConstants.cashMovement,
          PermissionConstants.reportsView,
          PermissionConstants.customerManage,
          // Explicitly adding Inventory View as it might be useful for checking stock during sale
          PermissionConstants.inventoryView,
        ];
      case UserRole.espectador:
        return [
          PermissionConstants.inventoryView,
          PermissionConstants.reportsView,
        ];
      case UserRole.administrador:
        return null; // Should not happen as admin doesn't see selector, but safe default
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = User(
        id: widget.user?.id,
        username: _usernameController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        role: _selectedRole,
        isActive: _isActive,
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save User Logic
      if (widget.user != null) {
        // Edit
        await ref.read(userProvider.notifier).modifyUser(user);
        // If cashier, also update permissions?
        // Current existing flow keeps permissions separate for editing, but we could merge.
        // For now, let's respect the user update.
        if (_selectedRole != UserRole.administrador) {
          await ref
              .read(cashierControllerProvider.notifier)
              .updatePermissions(user.id!, _selectedPermissionIds);
        }
      } else {
        // Create
        if (_selectedRole != UserRole.administrador) {
          // Create user with permissions logic
          await ref
              .read(cashierControllerProvider.notifier)
              .createCashier(user, _passwordController.text);

          final users = await ref.read(userProvider.future);
          final createdUser = users.firstWhere(
            (u) => u.username == user.username,
            orElse: () => user,
          );

          if (createdUser.id != null && _selectedPermissionIds.isNotEmpty) {
            await ref
                .read(cashierControllerProvider.notifier)
                .updatePermissions(createdUser.id!, _selectedPermissionIds);
          }
        } else {
          // Admin
          await ref
              .read(cashierControllerProvider.notifier)
              .createCashier(user, _passwordController.text);
        }
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.user != null
                  ? 'Usuario actualizado'
                  : 'Usuario creado exitosamente',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
