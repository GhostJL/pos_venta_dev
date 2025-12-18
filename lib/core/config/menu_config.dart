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
  final bool Function(User?)? visibilityCheck;

  const MenuGroup({
    required this.id,
    required this.title,
    required this.items,
    this.groupIcon,
    this.collapsible = true,
    this.defaultExpanded = true,
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
  static List<MenuGroup> getAdministratorMenu() {
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
        ],
      ),

      // ═══════════════════════════════════════════════════════════
      // SECCIÓN 2: INVENTARIO Y PRODUCTOS (Segunda más usada)
      // ═══════════════════════════════════════════════════════════
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
      MenuGroup(
        id: 'system_configuration',
        title: 'Configuración del Sistema',
        groupIcon: Icons.settings_rounded,
        defaultExpanded: false,
        visibilityCheck: (user) => user?.role == UserRole.administrador,
        items: [
          MenuItem(
            title: 'Mi Tienda',
            icon: Icons.store_mall_directory_rounded,
            route: '/profile',
            customAccessCheck: (user) => user?.role == UserRole.administrador,
          ),
          MenuItem(
            title: 'Usuarios y Permisos',
            icon: Icons.admin_panel_settings_rounded,
            route: '/cashiers',
            customAccessCheck: (user) => user?.role == UserRole.administrador,
          ),

          const MenuItem(
            title: 'Tasas de Impuesto',
            icon: Icons.price_change_rounded,
            route: '/tax-rates',
            requiredPermissions: [PermissionConstants.catalogManage],
          ),
          const MenuItem(
            title: 'Departamentos',
            icon: Icons.apartment_rounded,
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
        title: 'Historial de Ventas',
        icon: Icons.receipt_long_rounded,
        route: '/sales-history',
        requiredPermissions: [PermissionConstants.reportsView],
      ),
      const MenuItem(
        title: 'Gestión de Devoluciones',
        icon: Icons.keyboard_return_rounded,
        route: '/returns',
        requiredPermissions: [PermissionConstants.posAccess],
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
