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

/// Main side menu - Unified for Desktop (Sidebar) and Mobile (Drawer)
class SideMenu extends ConsumerStatefulWidget {
  final bool isCollapsed;
  final VoidCallback? onToggle;

  const SideMenu({super.key, this.isCollapsed = false, this.onToggle});

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: widget.isCollapsed ? 80 : 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          _MinimalHeader(
            user: ref.watch(authProvider).user,
            onToggle: widget.onToggle,
            isCollapsed: widget.isCollapsed,
          ),

          Expanded(child: _buildMenuContent(context)),

          const SizedBox(height: 8),
          _SettingsItem(
            user: ref.watch(authProvider).user,
            isCollapsed: widget.isCollapsed,
          ),
          const SizedBox(height: 8),
          SideMenuLogout(isCollapsed: widget.isCollapsed),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (!widget.isCollapsed) {
      // Prevent overflow errors during animation by forcing full width layout
      return OverflowBox(
        minWidth: 280,
        maxWidth: 280,
        alignment: Alignment.topLeft,
        child: content,
      );
    }

    return content;
  }

  Widget _buildMenuContent(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Center(child: Text("No user"));
    }

    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final permissions = permissionsAsync.asData?.value ?? [];
    final settings = ref.watch(settingsProvider);
    final useInventory = settings.value?.useInventory ?? true;

    final menuData = MenuConfig.getMenuForUser(
      user,
      useInventory: useInventory,
    );
    final useGroups = MenuConfig.shouldUseGroups(user);

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 0 : 12,
        vertical: 8,
      ),
      children: useGroups
          ? _buildGroupedMenu(
              context,
              menuData as List<MenuGroup>,
              user,
              permissions,
              currentPath,
            )
          : _buildFlatMenu(
              context,
              menuData as List<MenuItem>,
              user,
              permissions,
              currentPath,
            ),
    );
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

      if (i > 0 && !widget.isCollapsed) {
        widgets.add(const SizedBox(height: 4));
      }

      widgets.add(
        MenuGroupWidget(
          menuGroup: filteredGroup,
          currentPath: currentPath,
          isCollapsed: widget.isCollapsed,
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
    return items
        .where((item) => item.hasAccess(user, permissions))
        .map(
          (item) => MenuItemWidget(
            menuItem: item,
            currentPath: currentPath,
            isCollapsed: widget.isCollapsed,
          ),
        )
        .toList();
  }
}

class _MinimalHeader extends StatelessWidget {
  final User? user;
  final VoidCallback? onToggle;
  final bool isCollapsed;

  const _MinimalHeader({
    required this.user,
    this.onToggle,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.store_rounded, size: 32, color: colorScheme.primary),
            if (onToggle != null) ...[
              const SizedBox(height: 12),
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: onToggle,
                tooltip: 'Expandir menú',
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
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
            ],
          ),
          const SizedBox(height: 24),
          if (user != null) ...[
            Text(
              'Hola,',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user!.name,
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
          //... (removed)
        ],
      ),
    );
  }
}

class _SettingsItem extends ConsumerWidget {
  final User? user;
  final bool isCollapsed;

  const _SettingsItem({required this.user, required this.isCollapsed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if user has settings access (Admin or Manager)
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final permissions = permissionsAsync.asData?.value ?? [];

    // Quick check: If admin, always show. If not, check permission.
    // However, to supply 'permissions' here we need to read it from provider inside this widget or pass it down.
    // _SettingsItem is a separate widget, so it needs to watch the provider if it's not passed.
    // But it's stateless. Let's make it consumer or pass permissions.
    // To minimize refactor, let's just use the role check for now as we defined in Helper:
    // Admin has ALL, Manager has SETTINGS_ACCESS.
    // If we want to be strict about "permission driven", we should check the permission.

    // For now, simplify based on Role AND Permission existence concept
    final allowSettings =
        user?.role == UserRole.administrador || user?.role == UserRole.gerente;

    if (!allowSettings) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Tooltip(
        message: isCollapsed ? 'Configuración' : '',
        waitDuration: const Duration(milliseconds: 500),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              GoRouter.of(context).push('/settings');
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold?.isDrawerOpen ?? false) {
                scaffold!.closeDrawer();
              }
            },
            borderRadius: BorderRadius.circular(12),
            hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
            splashColor: colorScheme.primary.withValues(alpha: 0.12),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.settings_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Configuración',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
