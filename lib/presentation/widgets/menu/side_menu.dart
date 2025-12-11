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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();
    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final permissions = permissionsAsync.asData?.value ?? [];

    return SafeArea(
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          // Fondo adaptado al tema
          color: isDark
              ? colorScheme.surface
              : colorScheme.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header minimalista
            _MinimalHeader(user: user),

            // Campo de búsqueda
            _buildSearchBar(colorScheme),

            // Contenido del menú
            Expanded(
              child: _buildMenuContent(context, user, permissions, currentPath),
            ),

            // Logout button
            const SideMenuLogout(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar...',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            size: 20,
          ),
          filled: true,
          fillColor: colorScheme.surface.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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

      final filteredGroup = MenuGroup(
        id: group.id,
        title: group.title,
        groupIcon: group.groupIcon,
        items: accessibleItems,
        collapsible: group.collapsible,
        defaultExpanded: group.defaultExpanded,
      );

      if (i > 0) {
        widgets.add(const SizedBox(height: 4));
      }

      widgets.add(
        MenuGroupWidget(menuGroup: filteredGroup, currentPath: currentPath),
      );
    }

    if (widgets.isEmpty && _searchQuery.isNotEmpty) {
      widgets.add(_buildNoResults(context));
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

    var accessibleItems = items
        .where((item) => item.hasAccess(user, permissions))
        .toList();

    if (_searchQuery.isNotEmpty) {
      accessibleItems = accessibleItems
          .where((item) => item.title.toLowerCase().contains(_searchQuery))
          .toList();
    }

    for (final item in accessibleItems) {
      widgets.add(MenuItemWidget(menuItem: item, currentPath: currentPath));
    }

    if (accessibleItems.isEmpty && _searchQuery.isNotEmpty) {
      widgets.add(_buildNoResults(context));
    }

    return widgets;
  }

  Widget _buildNoResults(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Header minimalista adaptable al tema
class _MinimalHeader extends StatelessWidget {
  final User? user;

  const _MinimalHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.menu_rounded,
            size: 20,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          Text(
            'Menu',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
