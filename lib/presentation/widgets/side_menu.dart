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
          _buildQuickActions(context, user),
          _buildSearchBar(),
          Expanded(child: _buildMenuContent(user, permissions, currentPath)),
          _buildLogoutSection(context, ref),
        ],
      ),
    );
  }

  /// Build quick action buttons for common tasks
  Widget _buildQuickActions(BuildContext context, User? user) {
    if (user?.role == UserRole.cajero) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.borders.withAlpha(100)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACCIONES RÁPIDAS',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.point_of_sale_rounded,
                    label: 'POS',
                    color: Colors.green,
                    onTap: () => context.go('/sales'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.keyboard_return_rounded,
                    label: 'Devolución',
                    color: Colors.orange,
                    onTap: () => context.go('/returns'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Build search bar for menu filtering
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borders.withAlpha(100)),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar en menú...',
          hintStyle: TextStyle(
            color: AppTheme.textSecondary.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14),
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
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron resultados',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron resultados',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  /// Build drawer header with user info and cash session status
  Widget _buildDrawerHeader(BuildContext context, User? user) {
    final accountName = user?.firstName ?? 'Usuario';
    final accountLastName = user?.lastName ?? 'N.';
    final accountEmail = user != null
        ? (user.role == UserRole.administrador ? 'Administrador' : 'Cajero')
        : 'Rol no disponible';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppTheme.borders.withAlpha(100)),
        ),
      ),
      child: Column(
        children: [
          Row(
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
          // Cash session status indicator
          if (user?.role == UserRole.cajero) ...[
            const SizedBox(height: 16),
            _buildCashSessionStatus(ref),
          ],
        ],
      ),
    );
  }

  /// Build cash session status indicator
  Widget _buildCashSessionStatus(WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(getCurrentCashSessionUseCaseProvider).call(),
      builder: (context, snapshot) {
        final hasOpenSession = snapshot.data != null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hasOpenSession
                ? Colors.green.withAlpha(20)
                : Colors.orange.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasOpenSession
                  ? Colors.green.withAlpha(50)
                  : Colors.orange.withAlpha(50),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasOpenSession ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasOpenSession ? 'Caja Abierta' : 'Caja Cerrada',
                  style: TextStyle(
                    color: hasOpenSession ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build logout section at the bottom
  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borders.withAlpha(100))),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () async {
            if (Scaffold.of(context).isDrawerOpen) {
              Scaffold.of(context).closeDrawer();
            }

            final session = await ref
                .read(getCurrentCashSessionUseCaseProvider)
                .call();

            if (session != null && context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Caja Abierta'),
                  content: const Text(
                    'Tienes una sesión de caja abierta.\nDebe cerrarla antes de cerrar sesión.',
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
      ),
    );
  }
}

/// Quick action button widget
class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: widget.color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color.withAlpha(_isHovered ? 100 : 50),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(widget.icon, color: widget.color, size: 24),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
