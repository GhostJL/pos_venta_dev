import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();

    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final permissions = permissionsAsync.asData?.value ?? [];

    // Helper to check permission
    bool hasAccess(String permission) {
      if (user?.role == UserRole.administrador) return true;
      return permissions.contains(permission);
    }

    return Container(
      width: 280, // Slightly wider for better readability
      decoration: BoxDecoration(
        color: AppTheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDrawerHeader(context, user),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _buildSectionHeader('General'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  title: 'Panel de Control',
                  path: '/',
                  currentPath: currentPath,
                ),
                const SizedBox(height: 24),

                if (hasAccess(PermissionConstants.catalogManage) ||
                    hasAccess(PermissionConstants.inventoryView) ||
                    hasAccess(PermissionConstants.customerManage))
                  _buildSectionHeader('Gestión de Catálogo'),

                if (hasAccess(PermissionConstants.catalogManage)) ...[
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.inventory_2_rounded,
                    title: 'Productos',
                    path: '/products',
                    currentPath: currentPath,
                  ),
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
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.shopping_cart_rounded,
                    title: 'Compras',
                    path: '/purchases',
                    currentPath: currentPath,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.receipt_rounded,
                    title: 'Artículos de Compra',
                    path: '/purchase-items',
                    currentPath: currentPath,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.warehouse_rounded,
                    title: 'Almacenes',
                    path: '/warehouses',
                    currentPath: currentPath,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.price_change_rounded,
                    title: 'Tasas de Impuesto',
                    path: '/tax-rates',
                    currentPath: currentPath,
                  ),
                ],

                if (hasAccess(PermissionConstants.inventoryView))
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.inventory_2_rounded,
                    title: 'Inventario',
                    path: '/inventory',
                    currentPath: currentPath,
                  ),

                if (hasAccess(PermissionConstants.customerManage))
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.people_rounded,
                    title: 'Clientes',
                    path: '/customers',
                    currentPath: currentPath,
                  ),

                if (hasAccess(PermissionConstants.posAccess) ||
                    hasAccess(PermissionConstants.reportsView))
                  const SizedBox(height: 24),

                if (hasAccess(PermissionConstants.posAccess))
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.point_of_sale,
                    title: 'Ventas (POS)',
                    path: '/sales',
                    currentPath: currentPath,
                  ),

                if (hasAccess(PermissionConstants.reportsView))
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.receipt_long,
                    title: 'Historial de Ventas',
                    path: '/sales-history',
                    currentPath: currentPath,
                  ),

                if (user?.role == UserRole.administrador) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('Administración'),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.badge_rounded,
                    title: 'Cajeros',
                    path: '/cashiers',
                    currentPath: currentPath,
                  ),
                ],
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
    final accountLastName = user?.lastName ?? 'N.';

    final accountEmail = user != null
        ? (user.role == UserRole.administrador ? 'Administrador' : 'Cajero')
        : 'Rol no disponible';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppTheme.borders.withAlpha(100)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withAlpha(50),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primary.withAlpha(20),
              child: Text(
                accountName.isNotEmpty ? accountName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$accountName $accountLastName',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    accountEmail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
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
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.2,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          size: 22,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () {
          context.go(path);
          if (Scaffold.of(context).isDrawerOpen) {
            Scaffold.of(context).closeDrawer();
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected
            ? AppTheme.primary.withAlpha(15)
            : Colors.transparent,
        hoverColor: AppTheme.primary.withAlpha(5),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borders.withAlpha(100))),
      ),
      child: InkWell(
        onTap: () async {
          if (Scaffold.of(context).isDrawerOpen) {
            Scaffold.of(context).closeDrawer();
          }

          // Verificar si hay sesión de caja abierta
          final session = await ref
              .read(getCurrentCashSessionUseCaseProvider)
              .call();

          if (session != null && context.mounted) {
            // Mostrar diálogo obligando a cerrar caja
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Caja Abierta'),
                content: const Text(
                  'Tienes una sesión de caja abierta.\nDebe cerrarla antes de cerrar sesión.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/cash-session-close?intent=logout');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Ir a Cerrar Caja'),
                  ),
                ],
              ),
            );
          } else {
            ref.read(authProvider.notifier).logout();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.error.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
              SizedBox(width: 8),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
