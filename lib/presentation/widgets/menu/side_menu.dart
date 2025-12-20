import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/core/config/menu_config.dart';
import 'package:posventa/presentation/widgets/menu/menu_group_widget.dart';
import 'package:posventa/presentation/widgets/menu/menu_item_widget.dart';
import 'package:posventa/presentation/widgets/menu/side_menu/side_menu_logout.dart';

/// Main side menu adaptable a tema claro/oscuro
class SideMenu extends ConsumerStatefulWidget {
  const SideMenu({super.key});

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final permissions = permissionsAsync.asData?.value ?? [];

    return NavigationDrawer(
      elevation: 0,
      children: [
        // Header minimalista
        _MinimalHeader(user: user),

        // Contenido del menú
        ..._buildMenuContent(context, user, permissions, currentPath),

        const SizedBox(height: 16),
        // Logout button
        const SideMenuLogout(),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildMenuContent(
    BuildContext context,
    User? user,
    List<String> permissions,
    String currentPath,
  ) {
    if (user == null) {
      return [
        const NavigationDrawerDestination(
          icon: Icon(Icons.error),
          label: Text('No user logged in'),
        ),
      ];
    }

    final menuData = MenuConfig.getMenuForUser(user);
    final useGroups = MenuConfig.shouldUseGroups(user);

    if (useGroups) {
      return _buildGroupedMenu(
        context,
        menuData as List<MenuGroup>,
        user,
        permissions,
        currentPath,
      );
    } else {
      return _buildFlatMenu(
        context,
        menuData as List<MenuItem>,
        user,
        permissions,
        currentPath,
      );
    }
  }

  List<Widget> _buildGroupedMenu(
    BuildContext context,
    List<MenuGroup> groups,
    User user,
    List<String> permissions,
    String currentPath,
  ) {
    final widgets = <Widget>[];

    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];

      if (!group.isVisible(user, permissions)) continue;

      var accessibleItems = group.getAccessibleItems(user, permissions);

      if (accessibleItems.isEmpty && group.route == null) continue;

      final filteredGroup = MenuGroup(
        id: group.id,
        title: group.title,
        groupIcon: group.groupIcon,
        items: accessibleItems,
        collapsible: group.collapsible,
        defaultExpanded: group.defaultExpanded,
        route: group.route,
      );

      if (i > 0) {
        widgets.add(const SizedBox(height: 4));
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: MenuGroupWidget(
            menuGroup: filteredGroup,
            currentPath: currentPath,
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildFlatMenu(
    BuildContext context,
    List<MenuItem> items,
    User user,
    List<String> permissions,
    String currentPath,
  ) {
    final widgets = <Widget>[];

    final accessibleItems = items
        .where((item) => item.hasAccess(user, permissions))
        .toList();

    for (final item in accessibleItems) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: MenuItemWidget(menuItem: item, currentPath: currentPath),
        ),
      );
    }

    return widgets;
  }
}

/// Header minimalista adaptable al tema
class _MinimalHeader extends StatelessWidget {
  final User? user;

  const _MinimalHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 16, 20),
      child: Row(
        children: [
          Icon(Icons.store_rounded, size: 24, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            'POS Venta',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          if (user?.role == UserRole.administrador) ...[
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.settings_rounded, size: 20),
              onPressed: () {
                GoRouter.of(context).push('/settings');
                final scaffold = Scaffold.maybeOf(context);
                if (scaffold?.isDrawerOpen ?? false) {
                  scaffold!.closeDrawer();
                }
              },
              tooltip: 'Configuración',
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
