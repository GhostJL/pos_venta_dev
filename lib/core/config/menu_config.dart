import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/core/constants/permission_constants.dart';

/// Represents a single menu item in the navigation
class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final List<String>? requiredPermissions;
  final bool Function(User?)? customAccessCheck;
  final int? badgeCount;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.requiredPermissions,
    this.customAccessCheck,
    this.badgeCount,
  });

  /// Check if the user has access to this menu item
  bool hasAccess(User? user, List<String> userPermissions) {
    if (user?.role == UserRole.administrador) return true;
    if (customAccessCheck != null) {
      return customAccessCheck!(user);
    }
    if (requiredPermissions != null && requiredPermissions!.isNotEmpty) {
      return requiredPermissions!.any(
        (permission) => userPermissions.contains(permission),
      );
    }
    return true;
  }
}

/// Represents a group of menu items
class MenuGroup {
  final String id;
  final String title;
  final IconData? groupIcon;
  final List<MenuItem> items;
  final bool collapsible;
  final bool defaultExpanded;
  final String? route;
  final bool Function(User?)? visibilityCheck;

  const MenuGroup({
    required this.id,
    required this.title,
    required this.items,
    this.groupIcon,
    this.collapsible = true,
    this.defaultExpanded = true,
    this.route,
    this.visibilityCheck,
  });

  bool isVisible(User? user, List<String> userPermissions) {
    if (visibilityCheck != null) {
      return visibilityCheck!(user);
    }
    return items.any((item) => item.hasAccess(user, userPermissions));
  }

  List<MenuItem> getAccessibleItems(User? user, List<String> userPermissions) {
    return items
        .where((item) => item.hasAccess(user, userPermissions))
        .toList();
  }
}

/// Centralized menu configuration for the application
class MenuConfig {
  /// Get the complete administrator menu
  static List<MenuGroup> getAdministratorMenu({bool useInventory = true}) {
    return [
      // ═══════════════════════════════════════════════════════════
      // SECCIÓN 1: OPERACIONES DIARIAS (Más usado)
      // ═══════════════════════════════════════════════════════════
      MenuGroup(
        id: 'daily_operations',
        title: 'Operaciones Diarias',
        groupIcon: Icons.store_rounded,
        defaultExpanded: true,
        items: [
          const MenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard_rounded,
            route: '/',
          ),
          const MenuItem(
            title: 'Punto de Venta (POS)',
            icon: Icons.point_of_sale_rounded,
            route: '/sales',
            requiredPermissions: [PermissionConstants.posAccess],
          ),
          const MenuItem(
            title: 'Historial de Ventas',
            icon: Icons.receipt_long_rounded,
            route: '/sales-history',
            requiredPermissions: [PermissionConstants.reportsView],
          ),
          const MenuItem(
            title: 'Sesiones de Caja',
            icon: Icons.account_balance_wallet_rounded,
            route: '/cash-sessions-history',
            requiredPermissions: [PermissionConstants.reportsView],
          ),
          const MenuItem(
            title: 'Reportes y Analíticas',
            icon: Icons.bar_chart_rounded,
            route: '/reports',
            requiredPermissions: [PermissionConstants.reportsView],
          ),
        ],
      ),

      // ═══════════════════════════════════════════════════════════
      // SECCIÓN 2: INVENTARIO Y PRODUCTOS (Segunda más usada)
      // ═══════════════════════════════════════════════════════════
      if (useInventory)
        MenuGroup(
          id: 'inventory_management',
          title: 'Inventario y Productos',
          groupIcon: Icons.inventory_2_rounded,
          defaultExpanded: false,
          items: [
            const MenuItem(
              title: 'Catálogo de Productos',
              icon: Icons.shopping_bag_rounded,
              route: '/products',
              requiredPermissions: [PermissionConstants.catalogManage],
            ),
            const MenuItem(
              title: 'Inventario',
              icon: Icons.inventory_rounded,
              route: '/inventory',
              requiredPermissions: [PermissionConstants.inventoryView],
            ),

            const MenuItem(
              title: 'Órdenes de Compra',
              icon: Icons.shopping_cart_rounded,
              route: '/purchases',
              requiredPermissions: [PermissionConstants.catalogManage],
            ),
          ],
        )
      else
        // Simplified product management for non-inventory users
        MenuGroup(
          id: 'product_management',
          title: 'Productos',
          groupIcon: Icons.shopping_bag_rounded,
          defaultExpanded: false,
          items: [
            const MenuItem(
              title: 'Catálogo de Productos',
              icon: Icons.shopping_bag_rounded,
              route: '/products',
              requiredPermissions: [PermissionConstants.catalogManage],
            ),
            const MenuItem(
              title: 'Órdenes de Compra',
              icon: Icons.shopping_cart_rounded,
              route: '/purchases',
              requiredPermissions: [PermissionConstants.catalogManage],
            ),
          ],
        ),

      // ═══════════════════════════════════════════════════════════
      // SECCIÓN 3: RELACIONES COMERCIALES
      // ═══════════════════════════════════════════════════════════
      MenuGroup(
        id: 'business_relations',
        title: 'Clientes y Proveedores',
        groupIcon: Icons.people_rounded,
        defaultExpanded: false,
        items: [
          const MenuItem(
            title: 'Clientes',
            icon: Icons.person_rounded,
            route: '/customers',
            requiredPermissions: [PermissionConstants.customerManage],
          ),
          const MenuItem(
            title: 'Cuentas por Cobrar',
            icon: Icons.payments_rounded,
            route: '/customers/debt',
            requiredPermissions: [PermissionConstants.customerManage],
          ),
          const MenuItem(
            title: 'Proveedores',
            icon: Icons.local_shipping_rounded,
            route: '/suppliers',
            requiredPermissions: [PermissionConstants.catalogManage],
          ),
        ],
      ),

      // ═══════════════════════════════════════════════════════════
      // SECCIÓN 4: CONFIGURACIÓN DEL SISTEMA (Solo Admin)
      // ═══════════════════════════════════════════════════════════
    ];
  }

  /// Get the simplified cashier menu
  static List<MenuItem> getCashierMenu() {
    return [
      const MenuItem(
        title: 'Inicio',
        icon: Icons.dashboard_rounded,
        route: '/home',
      ),
      const MenuItem(
        title: 'Punto de Venta (POS)',
        icon: Icons.point_of_sale_rounded,
        route: '/sales',
        requiredPermissions: [PermissionConstants.posAccess],
      ),
      const MenuItem(
        title: 'Historial de Ventas',
        icon: Icons.receipt_long_rounded,
        route: '/sales-history',
        requiredPermissions: [PermissionConstants.reportsView],
      ),
    ];
  }

  /// Get menu configuration based on user role
  static dynamic getMenuForUser(User? user, {bool useInventory = true}) {
    if (user == null) return <MenuGroup>[];

    // Cashiers get a flat list of menu items (no groups)
    if (user.role == UserRole.cajero) {
      return getCashierMenu();
    }

    // Administrators and other roles get grouped menu
    return getAdministratorMenu(useInventory: useInventory);
  }

  /// Check if the menu should use groups (true) or flat list (false)
  static bool shouldUseGroups(User? user) {
    return user?.role != UserRole.cajero;
  }
}
