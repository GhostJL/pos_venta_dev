import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/core/config/menu_config.dart';
import 'package:posventa/presentation/widgets/menu/menu_group_widget.dart';
import 'package:posventa/presentation/widgets/menu/menu_item_widget.dart';

/// Main side menu navigation widget with role-based access control
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

    return Container(
      width: 280,
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
          Expanded(child: _buildMenuContent(user, permissions, currentPath)),
          _buildLogoutSection(context, ref),
        ],
      ),
    );
  }

  /// Build menu content based on user role
  Widget _buildMenuContent(
    User? user,
    List<String> permissions,
    String currentPath,
  ) {
    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    final menuData = MenuConfig.getMenuForUser(user);
    final useGroups = MenuConfig.shouldUseGroups(user);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        if (useGroups)
          ..._buildGroupedMenu(
            menuData as List<MenuGroup>,
            user,
            permissions,
            currentPath,
          )
        else
          ..._buildFlatMenu(
            menuData as List<MenuItem>,
            user,
            permissions,
            currentPath,
          ),
      ],
    );
  }

  /// Build grouped menu for administrators
  List<Widget> _buildGroupedMenu(
    List<MenuGroup> groups,
    User user,
    List<String> permissions,
    String currentPath,
  ) {
    final widgets = <Widget>[];

    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];

      // Check if group should be visible
      if (!group.isVisible(user, permissions)) continue;

      // Get accessible items
      final accessibleItems = group.getAccessibleItems(user, permissions);
      if (accessibleItems.isEmpty) continue;

      // Create a filtered group with only accessible items
      final filteredGroup = MenuGroup(
        title: group.title,
        groupIcon: group.groupIcon,
        items: accessibleItems,
        collapsible: group.collapsible,
        defaultExpanded: group.defaultExpanded,
      );

      // Add spacing before group (except first one)
      if (i > 0) {
        widgets.add(const SizedBox(height: 24));
      }

      // Add the group widget
      widgets.add(
        MenuGroupWidget(menuGroup: filteredGroup, currentPath: currentPath),
      );
    }

    return widgets;
  }

  /// Build flat menu for cashiers
  List<Widget> _buildFlatMenu(
    List<MenuItem> items,
    User user,
    List<String> permissions,
    String currentPath,
  ) {
    final widgets = <Widget>[];

    // Add section header for cashiers
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
        child: Text(
          'MENÚ PRINCIPAL',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );

    // Filter items based on permissions
    final accessibleItems = items
        .where((item) => item.hasAccess(user, permissions))
        .toList();

    // Add menu items
    for (final item in accessibleItems) {
      widgets.add(MenuItemWidget(menuItem: item, currentPath: currentPath));
    }

    return widgets;
  }

  /// Build drawer header with user info
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
                Text(
                  accountEmail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build logout section at the bottom
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

          // Check for open cash session
          final session = await ref
              .read(getCurrentCashSessionUseCaseProvider)
              .call();

          if (session != null && context.mounted) {
            // Show dialog requiring cash session closure
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Caja Abierta'),
                content: const Text(
                  'Tienes una sesión de caja abierta.\\nDebe cerrarla antes de cerrar sesión.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      context.pop();
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
