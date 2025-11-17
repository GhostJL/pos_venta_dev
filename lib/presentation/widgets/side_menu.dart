import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();

    return Container(
      width: 260,
      color: AppTheme.background,
      child: Column(
        children: [
          _buildDrawerHeader(context, user),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionHeader('General'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  title: 'Panel de Control',
                  path: '/',
                  currentPath: currentPath,
                ),
                const SizedBox(height: 12),
                _buildSectionHeader('Gestión de Catálogo'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.store_rounded,
                  title: 'Departamentos',
                  path: '/departments',
                  currentPath: currentPath,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.category_rounded,
                  title: 'Categorías',
                  path: '/categories',
                  currentPath: currentPath,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.label_rounded,
                  title: 'Marcas',
                  path: '/brands',
                  currentPath: currentPath,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.local_shipping_rounded,
                  title: 'Proveedores',
                  path: '/suppliers',
                  currentPath: currentPath,
                ),
              ],
            ),
          ),
          _buildLogoutSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, User? user) {
    final accountName = user?.firstName ?? 'Usuario';
    final accountEmail = user != null
        ? (user.role == UserRole.administrador ? 'Administrador' : 'Cajero')
        : 'Rol no disponible';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primary,
            child: Text(
              accountName.isNotEmpty ? accountName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  accountEmail,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSecondary.withOpacity(0.7),
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String path,
    required String currentPath,
  }) {
    final bool isSelected = currentPath == path;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
        onTap: () {
          // Navigate to the new page
          context.go(path);
          // If the drawer is open (on small screens), close it
          if (Scaffold.of(context).isDrawerOpen) {
            Scaffold.of(context).closeDrawer();
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: AppTheme.primary.withOpacity(0.1),
        selectedColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          // First, close the drawer if it's open
          if (Scaffold.of(context).isDrawerOpen) {
            Scaffold.of(context).closeDrawer();
          }
          // Then, perform the logout action
          ref.read(authProvider.notifier).logout();
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: AppTheme.error, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ).copyWith(
            fixedSize: WidgetStateProperty.all(const Size.fromWidth(double.maxFinite))
        ),
      ),
    );
  }
}
