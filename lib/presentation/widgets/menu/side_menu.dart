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
import 'package:posventa/presentation/providers/settings_provider.dart';

/// Main side menu adaptable a tema claro/oscuro
class SideMenu extends ConsumerStatefulWidget {
  final bool isRail;
  final VoidCallback? onToggle;
  const SideMenu({super.key, this.isRail = false, this.onToggle});

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  @override
  Widget build(BuildContext context) {
    if (widget.isRail) {
      return _buildRail(context);
    }
    return _buildDrawer(context);
  }

  Widget _buildRail(BuildContext context) {
    // NavigationRail implementation
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final permissions = permissionsAsync.asData?.value ?? [];

    final settings = ref.watch(settingsProvider);
    final useInventory = settings.value?.useInventory ?? true;

    if (user == null) return const SizedBox.shrink();

    final menuData = MenuConfig.getMenuForUser(
      user,
      useInventory: useInventory,
    );
    final useGroups = MenuConfig.shouldUseGroups(user);

    // Flatten items for Rail if grouped, or finding better way?
    // NavigationRail usually doesn't do headers well. Flattening is best + Tooltips.

    List<MenuItem> allItems = [];
    if (useGroups) {
      for (var group in (menuData as List<MenuGroup>)) {
        if (!group.isVisible(user, permissions)) continue;
        if (group.route != null) {
          // Group acts as item
          allItems.add(
            MenuItem(
              title: group.title,
              icon: group.groupIcon ?? Icons.circle,
              route: group.route!,
              requiredPermissions: null,
            ),
          );
        }
        allItems.addAll(group.getAccessibleItems(user, permissions));
      }
    } else {
      allItems = (menuData as List<MenuItem>)
          .where((item) => item.hasAccess(user, permissions))
          .toList();
    }

    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();
    // Simplified selection logic: matches path start
    int? selectedIndex;
    for (int i = 0; i < allItems.length; i++) {
      if (currentPath.startsWith(allItems[i].route)) {
        selectedIndex = i;
        break;
      }
    }

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        context.go(allItems[index].route);
      },
      labelType: NavigationRailLabelType.none,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onToggle,
          tooltip: 'Expandir menú',
        ),
      ),
      destinations: allItems.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          label: Text(item.title),
        );
      }).toList(),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: const SideMenuLogout(isRail: true),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final permissions = permissionsAsync.asData?.value ?? [];

    final settings = ref.watch(settingsProvider);
    final useInventory = settings.value?.useInventory ?? true;

    return OverflowBox(
      minWidth: 280,
      maxWidth: 280,
      alignment: Alignment.topLeft,
      child: NavigationDrawer(
        elevation: 0,
        children: [
          // Header minimalista
          _MinimalHeader(user: user, onToggle: widget.onToggle),

          // Contenido del menú
          ..._buildMenuContent(
            context,
            user,
            permissions,
            currentPath,
            useInventory,
          ),

          const SizedBox(height: 16),
          // Logout button
          const SideMenuLogout(isRail: false),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildMenuContent(
    BuildContext context,
    User? user,
    List<String> permissions,
    String currentPath,
    bool useInventory,
  ) {
    if (user == null) {
      return [
        const NavigationDrawerDestination(
          icon: Icon(Icons.error),
          label: Text('No user logged in'),
        ),
      ];
    }

    final menuData = MenuConfig.getMenuForUser(
      user,
      useInventory: useInventory,
    );
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

/// Header minimalista adaptable al tema con información del usuario
class _MinimalHeader extends StatelessWidget {
  final User? user;
  final VoidCallback? onToggle;

  const _MinimalHeader({required this.user, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        28,
        24,
        28,
        24,
      ), // Standard M3 drawer padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store_rounded, size: 28, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'POS Venta',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onToggle != null)
                IconButton(
                  icon: const Icon(Icons.menu_open_rounded),
                  onPressed: onToggle,
                  tooltip: 'Contraer menú',
                  color: colorScheme.onSurfaceVariant,
                ),
              if (user?.role == UserRole.administrador) ...[
                const SizedBox(width: 4),
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
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          // User Info Section
          if (user != null) ...[
            Text(
              'Hola,',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user!.name, // Ensure user has a name field or use username
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user!.role.name.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
