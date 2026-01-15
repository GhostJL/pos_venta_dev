class PermissionConstants {
  // POS Module
  static const String posAccess = 'POS_ACCESS';
  static const String posDiscount = 'POS_DISCOUNT';
  static const String posRefund = 'POS_REFUND';
  static const String posVoidItem = 'POS_VOID_ITEM';

  // Cash Module
  static const String cashOpen = 'CASH_OPEN';
  static const String cashClose = 'CASH_CLOSE';
  static const String cashMovement = 'CASH_MOVEMENT';

  // Inventory Module
  static const String inventoryView = 'INVENTORY_VIEW';
  static const String inventoryAdjust = 'INVENTORY_ADJUST';

  // Reports Module
  static const String reportsView = 'REPORTS_VIEW';

  // Catalog Module
  static const String catalogManage = 'CATALOG_MANAGE';

  // Customer Module
  static const String customerManage = 'CUSTOMER_MANAGE';

  // User Module
  static const String userManage = 'USER_MANAGE';

  // Settings Module
  static const String settingsAccess = 'SETTINGS_ACCESS';
  static const String systemManage = 'SYSTEM_MANAGE'; // Backups, Hardware, etc.

  // Default Cashier Permissions
  static const List<String> defaultCashierPermissions = [
    posAccess,
    cashOpen,
    cashClose,
    cashMovement,
    reportsView,
    posRefund,
    posVoidItem,
  ];

  // Default Manager Permissions
  static const List<String> defaultManagerPermissions = [
    posAccess,
    posDiscount,
    posRefund,
    posVoidItem,
    cashOpen,
    cashClose,
    cashMovement,
    inventoryView,
    inventoryAdjust,
    reportsView,
    catalogManage,
    customerManage,
    settingsAccess, // Can access settings but limited
  ];
}
