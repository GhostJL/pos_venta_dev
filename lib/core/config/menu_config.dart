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
    // Administrators always have access
    if (user?.role == UserRole.administrador) return true;

    // Custom access check takes precedence
    if (customAccessCheck != null) {
      return customAccessCheck!(user);
    }

    // Check required permissions
    if (requiredPermissions != null && requiredPermissions!.isNotEmpty) {
      return requiredPermissions!.any(
        (permission) => userPermissions.contains(permission),
      );
    }

    // No restrictions, allow access
    return true;
  }
}

/// Represents a group of menu items
class MenuGroup {
  final String title;
  final IconData? groupIcon;
  final List<MenuItem> items;
  final bool collapsible;
  final bool defaultExpanded;
  final bool Function(User?)? visibilityCheck;

  const MenuGroup({
    required this.title,
    required this.items,
    this.groupIcon,
    this.collapsible = true,
    this.defaultExpanded = true,
    this.visibilityCheck,
  });

  /// Check if this group should be visible to the user
  bool isVisible(User? user, List<String> userPermissions) {
    // Custom visibility check
    if (visibilityCheck != null) {
      return visibilityCheck!(user);
    }

    // Group is visible if at least one item is accessible
    return items.any((item) => item.hasAccess(user, userPermissions));
  }

  /// Get filtered items that the user can access
  List<MenuItem> getAccessibleItems(User? user, List<String> userPermissions) {
    return items
        .where((item) => item.hasAccess(user, userPermissions))
        .toList();
  }
}

/// Centralized menu configuration for the application
class MenuConfig {
  /// Get the complete administrator menu
  static List<MenuGroup> getAdministratorMenu() {
    return [
      // Grupo 1: Inicio y Transacciones
      MenuGroup(
        title: 'Inicio y Transacciones',
        groupIcon: Icons.home_rounded,
        defaultExpanded: true,
        items: [
          const MenuItem(
            title: 'Dashboard Principal',
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
        ],
      ),

      // Grupo 2: Gestión de Efectivo
      MenuGroup(
        title: 'Gestión de Efectivo',
        groupIcon: Icons.account_balance_wallet_rounded,
        defaultExpanded: true,
        items: [
          const MenuItem(
            title: 'Gestión de Sesiones de Caja',
            icon: Icons.history_edu_rounded,
            route: '/cash-sessions-history',
            requiredPermissions: [PermissionConstants.reportsView],
          ),
          const MenuItem(
            title: 'Movimientos de Caja',
            icon: Icons.monetization_on_rounded,
            route: '/cash-movements-report',
            requiredPermissions: [PermissionConstants.reportsView],
          ),
        ],
      ),

      // Grupo 3: Inventario y Compras
      MenuGroup(
        title: 'Inventario y Compras',
        groupIcon: Icons.inventory_rounded,
        defaultExpanded: true,
        items: [
          const MenuItem(
            title: 'Catálogo de Productos',
            icon: Icons.inventory_2_rounded,
            route: '/products',
            requiredPermissions: [PermissionConstants.catalogManage],
          ),
          const MenuItem(
            title: 'Órdenes de Compra (OCs)',
            icon: Icons.shopping_cart_rounded,
            route: '/purchases',
            requiredPermissions: [PermissionConstants.catalogManage],
          ),
          const MenuItem(
            title: 'Ajustes de Inventario',
            icon: Icons.tune_rounded,
            route: '/inventory-adjustments-menu',
            requiredPermissions: [PermissionConstants.inventoryView],
          ),
        ],
      ),

      // Grupo 4: Catálogos Base
      MenuGroup(
        title: 'Catálogos Base',
        groupIcon: Icons.folder_rounded,
        defaultExpanded: true,
        items: [
          const MenuItem(
            title: 'Clientes',
            icon: Icons.people_rounded,
            route: '/customers',
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

      // Grupo 5: Administración
      MenuGroup(
        title: 'Administración',
        groupIcon: Icons.admin_panel_settings_rounded,
        defaultExpanded: true,
        visibilityCheck: (user) => user?.role == UserRole.administrador,
        items: [
          MenuItem(
            title: 'Usuarios y Permisos',
            icon: Icons.badge_rounded,
            route: '/users-permissions',
            customAccessCheck: (user) => user?.role == UserRole.administrador,
          ),
          MenuItem(
            title: 'Configuración de Impuestos y Tiendas',
            icon: Icons.settings_rounded,
            route: '/tax-store-config',
            customAccessCheck: (user) => user?.role == UserRole.administrador,
          ),
        ],
      ),

      // Grupo 6: Configuración Avanzada (Collapsed by default)
      MenuGroup(
        title: 'Configuración Avanzada',
        groupIcon: Icons.settings_applications_rounded,
        defaultExpanded: false,
        visibilityCheck: (user) => user?.role == UserRole.administrador,
        items: [
          const MenuItem(
            title: 'Departamentos',
            icon: Icons.store_rounded,
            route: '/departments',
            requiredPermissions: [PermissionConstants.catalogManage],
          ),
          const MenuItem(
            title: 'Categorías',
            icon: Icons.category_rounded,
            route: '/categories',
            requiredPermissions: [PermissionConstants.catalogManage],
          ),
          const MenuItem(
            title: 'Marcas',
            icon: Icons.label_rounded,
            route: '/brands',
            requiredPermissions: [PermissionConstants.catalogManage],
          ),
          const MenuItem(
            title: 'Almacenes',
            icon: Icons.warehouse_rounded,
            route: '/warehouses',
            requiredPermissions: [PermissionConstants.catalogManage],
          ),
          const MenuItem(
            title: 'Tasas de Impuesto',
            icon: Icons.price_change_rounded,
            route: '/tax-rates',
            requiredPermissions: [PermissionConstants.catalogManage],
          ),
          const MenuItem(
            title: 'Inventario (Stock)',
            icon: Icons.inventory_rounded,
            route: '/inventory',
            requiredPermissions: [PermissionConstants.inventoryView],
          ),
          const MenuItem(
            title: 'Movimientos de Inventario',
            icon: Icons.swap_horiz_rounded,
            route: '/inventory/movements',
            requiredPermissions: [PermissionConstants.inventoryView],
          ),
          MenuItem(
            title: 'Cajeros',
            icon: Icons.person_rounded,
            route: '/cashiers',
            customAccessCheck: (user) => user?.role == UserRole.administrador,
          ),
        ],
      ),
    ];
  }

  /// Get the simplified cashier menu
  static List<MenuItem> getCashierMenu() {
    return [
      const MenuItem(
        title: 'Punto de Venta (POS)',
        icon: Icons.point_of_sale_rounded,
        route: '/sales',
        requiredPermissions: [PermissionConstants.posAccess],
      ),
      const MenuItem(
        title: 'Gestión de Devoluciones',
        icon: Icons.keyboard_return_rounded,
        route: '/returns',
        requiredPermissions: [PermissionConstants.posAccess],
      ),
      const MenuItem(
        title: 'Movimientos de Caja',
        icon: Icons.monetization_on_rounded,
        route: '/cash-movements-report',
        requiredPermissions: [PermissionConstants.reportsView],
      ),
      const MenuItem(
        title: 'Cierre de Turno',
        icon: Icons.lock_clock_rounded,
        route: '/shift-close',
        requiredPermissions: [PermissionConstants.posAccess],
      ),
    ];
  }

  /// Get menu configuration based on user role
  static dynamic getMenuForUser(User? user) {
    if (user == null) return <MenuGroup>[];

    // Cashiers get a flat list of menu items (no groups)
    if (user.role == UserRole.cajero) {
      return getCashierMenu();
    }

    // Administrators and other roles get grouped menu
    return getAdministratorMenu();
  }

  /// Check if the menu should use groups (true) or flat list (false)
  static bool shouldUseGroups(User? user) {
    return user?.role != UserRole.cajero;
  }
}
