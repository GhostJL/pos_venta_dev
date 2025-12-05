import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/core/config/menu_config.dart';
import 'package:posventa/presentation/widgets/menu/menu_group_widget.dart';
import 'package:posventa/presentation/widgets/menu/menu_item_widget.dart';
import 'package:posventa/presentation/widgets/menu/side_menu/side_menu_header.dart';
import 'package:posventa/presentation/widgets/menu/side_menu/side_menu_logout.dart';
import 'package:posventa/presentation/widgets/menu/side_menu/side_menu_quick_actions.dart';
import 'package:posventa/presentation/widgets/menu/side_menu/side_menu_search_bar.dart';

/// Main side menu navigation widget with enhanced UX for POS
class SideMenu extends ConsumerStatefulWidget {
  const SideMenu({super.key});

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();

    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final permissions = permissionsAsync.asData?.value ?? [];

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
          SideMenuHeader(user: user),
          SideMenuQuickActions(user: user),
          SideMenuSearchBar(
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            onClear: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          Expanded(
            child: _buildMenuContent(context, user, permissions, currentPath),
          ),
          const SideMenuLogout(),
        ],
      ),
    );
  }

  /// Build menu content based on user role
  Widget _buildMenuContent(
    BuildContext context,
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
            context,
            menuData as List<MenuGroup>,
            user,
            permissions,
            currentPath,
          )
        else
          ..._buildFlatMenu(
            context,
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
    BuildContext context,
    List<MenuGroup> groups,
    User user,
    List<String> permissions,
    String currentPath,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final widgets = <Widget>[];

    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];

      // Check if group should be visible
      if (!group.isVisible(user, permissions)) continue;

      // Get accessible items
      var accessibleItems = group.getAccessibleItems(user, permissions);

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        accessibleItems = accessibleItems
            .where(
              (item) =>
                  item.title.toLowerCase().contains(_searchQuery) ||
                  group.title.toLowerCase().contains(_searchQuery),
            )
            .toList();
      }

      if (accessibleItems.isEmpty) continue;

      // Create a filtered group with only accessible items
      final filteredGroup = MenuGroup(
        id: group.id,
        title: group.title,
        groupIcon: group.groupIcon,
        items: accessibleItems,
        collapsible: group.collapsible,
        defaultExpanded: group.defaultExpanded,
      );

      // Add spacing before group (except first one)
      if (i > 0) {
        widgets.add(const SizedBox(height: 20));
      }

      // Add the group widget
      widgets.add(
        MenuGroupWidget(menuGroup: filteredGroup, currentPath: currentPath),
      );
    }

    // Show "no results" message if search yields nothing
    if (widgets.isEmpty && _searchQuery.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron resultados',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  /// Build flat menu for cashiers
  List<Widget> _buildFlatMenu(
    BuildContext context,
    List<MenuItem> items,
    User user,
    List<String> permissions,
    String currentPath,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final widgets = <Widget>[];

    // Add section header for cashiers
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
        child: Text(
          'MENÚ PRINCIPAL',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );

    // Filter items based on permissions and search
    var accessibleItems = items
        .where((item) => item.hasAccess(user, permissions))
        .toList();

    if (_searchQuery.isNotEmpty) {
      accessibleItems = accessibleItems
          .where((item) => item.title.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Add menu items
    for (final item in accessibleItems) {
      widgets.add(MenuItemWidget(menuItem: item, currentPath: currentPath));
    }

    // Show "no results" message if search yields nothing
    if (accessibleItems.isEmpty && _searchQuery.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron resultados',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }
}
