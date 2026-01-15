import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/user_provider.dart';
import 'package:posventa/presentation/widgets/users/admin_change_password_dialog.dart';

/// Users List Page - Displays all users with management actions
class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key});

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  UserRole? _selectedRoleFilter;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userProvider);
    final currentUser = ref.watch(authProvider).user;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Usuarios y Permisos',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Filter by role
          PopupMenuButton<UserRole?>(
            icon: Icon(Icons.filter_list_rounded, color: colorScheme.onSurface),
            tooltip: 'Filtrar por rol',
            onSelected: (role) {
              setState(() {
                _selectedRoleFilter = role;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      Icons.clear_all_rounded,
                      color: _selectedRoleFilter == null
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Todos',
                      style: TextStyle(
                        fontWeight: _selectedRoleFilter == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              ...UserRole.values.map(
                (role) => PopupMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      Icon(
                        _getRoleIcon(role),
                        color: _selectedRoleFilter == role
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getRoleLabel(role),
                        style: TextStyle(
                          fontWeight: _selectedRoleFilter == role
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () {
              ref.read(userProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          // Apply filter
          final filteredUsers = _selectedRoleFilter == null
              ? users
              : users.where((u) => u.role == _selectedRoleFilter).toList();

          if (filteredUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedRoleFilter == null
                        ? 'No hay usuarios registrados'
                        : 'No hay usuarios con el rol seleccionado',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 600;

              if (isDesktop) {
                return _buildDesktopLayout(
                  filteredUsers,
                  currentUser,
                  colorScheme,
                );
              } else {
                return _buildMobileLayout(
                  filteredUsers,
                  currentUser,
                  colorScheme,
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar usuarios',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    List<User> users,
    User? currentUser,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Usuario',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Nombre de Usuario',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rol',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Estado',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 80),
                    ],
                  ),
                ),
                // Table Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: colorScheme.outlineVariant),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isCurrentUser = user.id == currentUser?.id;

                    return _buildDesktopUserRow(
                      user,
                      isCurrentUser,
                      colorScheme,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopUserRow(
    User user,
    bool isCurrentUser,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // User Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    user.firstName.isNotEmpty
                        ? user.firstName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (user.email != null && user.email!.isNotEmpty)
                        Text(
                          user.email!,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Username
          Expanded(
            flex: 2,
            child: Text(
              '@${user.username}',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Role
          Expanded(flex: 2, child: _buildRoleChip(user.role, colorScheme)),
          // Status
          Expanded(
            flex: 1,
            child: _buildStatusChip(user.isActive, colorScheme),
          ),
          // Actions
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCurrentUser)
                  Chip(
                    label: const Text('Tú'),
                    labelStyle: const TextStyle(fontSize: 11),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )
                else
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_reset_rounded,
                              color: colorScheme.onSurface,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text('Cambiar Contraseña'),
                          ],
                        ),
                        onTap: () => _showChangePasswordDialog(user),
                      ),
                      if (user.role == UserRole.cajero)
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.security_rounded,
                                color: colorScheme.onSurface,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text('Gestionar Permisos'),
                            ],
                          ),
                          onTap: () => _navigateToPermissions(user),
                        ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              user.isActive
                                  ? Icons.block_rounded
                                  : Icons.check_circle_rounded,
                              color: colorScheme.onSurface,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(user.isActive ? 'Desactivar' : 'Activar'),
                          ],
                        ),
                        onTap: () => _toggleUserStatus(user),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    List<User> users,
    User? currentUser,
    ColorScheme colorScheme,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        final isCurrentUser = user.id == currentUser?.id;

        return _buildMobileUserCard(user, isCurrentUser, colorScheme);
      },
    );
  }

  Widget _buildMobileUserCard(
    User user,
    bool isCurrentUser,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  radius: 24,
                  child: Text(
                    user.firstName.isNotEmpty
                        ? user.firstName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (isCurrentUser)
                            Chip(
                              label: const Text('Tú'),
                              labelStyle: const TextStyle(fontSize: 11),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRoleChip(user.role, colorScheme),
                const SizedBox(width: 8),
                _buildStatusChip(user.isActive, colorScheme),
              ],
            ),
            if (!isCurrentUser) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showChangePasswordDialog(user),
                      icon: const Icon(Icons.lock_reset_rounded, size: 18),
                      label: const Text('Cambiar Contraseña'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (user.role == UserRole.cajero)
                    IconButton(
                      onPressed: () => _navigateToPermissions(user),
                      icon: const Icon(Icons.security_rounded),
                      tooltip: 'Permisos',
                    ),
                  IconButton(
                    onPressed: () => _toggleUserStatus(user),
                    icon: Icon(
                      user.isActive
                          ? Icons.block_rounded
                          : Icons.check_circle_rounded,
                    ),
                    tooltip: user.isActive ? 'Desactivar' : 'Activar',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(UserRole role, ColorScheme colorScheme) {
    return Chip(
      avatar: Icon(
        _getRoleIcon(role),
        size: 16,
        color: colorScheme.onSecondaryContainer,
      ),
      label: Text(_getRoleLabel(role), style: const TextStyle(fontSize: 12)),
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatusChip(bool isActive, ColorScheme colorScheme) {
    return Chip(
      label: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: isActive
          ? colorScheme.tertiaryContainer
          : colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: isActive
            ? colorScheme.onTertiaryContainer
            : colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.administrador:
        return Icons.admin_panel_settings_rounded;
      case UserRole.gerente:
        return Icons.manage_accounts_rounded;
      case UserRole.cajero:
        return Icons.point_of_sale_rounded;
      case UserRole.espectador:
        return Icons.visibility_rounded;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.gerente:
        return 'Gerente';
      case UserRole.cajero:
        return 'Cajero';
      case UserRole.espectador:
        return 'Espectador';
    }
  }

  Future<void> _showChangePasswordDialog(User user) async {
    // Wait a frame to avoid popup menu animation conflict
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AdminChangePasswordDialog(user: user),
    );

    if (result == true && mounted) {
      // Refresh the users list
      ref.read(userProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToPermissions(User user) async {
    // Wait a frame to avoid popup menu animation conflict
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    context.push('/cashiers/permissions', extra: user);
  }

  Future<void> _toggleUserStatus(User user) async {
    // Wait a frame to avoid popup menu animation conflict
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    try {
      final updatedUser = user.copyWith(isActive: !user.isActive);
      await ref.read(userProvider.notifier).modifyUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActive
                  ? '${user.name} ha sido desactivado'
                  : '${user.name} ha sido activado',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            showCloseIcon: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            showCloseIcon: true,
          ),
        );
      }
    }
  }
}
