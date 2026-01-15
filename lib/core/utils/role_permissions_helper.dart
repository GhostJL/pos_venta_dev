import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/core/constants/permission_constants.dart';

class RolePermissionsHelper {
  /// Returns the list of default permissions for a given role.
  static List<String> getPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.administrador:
        // Admin has potential access to everything.
        // In this system, 'admin' usually bypasses checks, but we can list them explicitly if we want strict checking.
        // For simplicity, we might not strictly need a list if the check uses (role == admin || permission)
        // But let's return a "ALL" list or just everything for consistency if needed.
        return [
          PermissionConstants.posAccess,
          PermissionConstants.posDiscount,
          PermissionConstants.posRefund,
          PermissionConstants.posVoidItem,
          PermissionConstants.cashOpen,
          PermissionConstants.cashClose,
          PermissionConstants.cashMovement,
          PermissionConstants.inventoryView,
          PermissionConstants.inventoryAdjust,
          PermissionConstants.reportsView,
          PermissionConstants.catalogManage,
          PermissionConstants.customerManage,
          PermissionConstants.userManage,
          PermissionConstants.settingsAccess,
          PermissionConstants.systemManage,
        ];
      case UserRole.gerente:
        return PermissionConstants.defaultManagerPermissions;
      case UserRole.cajero:
        return PermissionConstants.defaultCashierPermissions;
      case UserRole.espectador:
        return [];
    }
  }

  /// Checks if a list of permissions contains a specific required permission.
  static bool hasPermission(
    List<String> userPermissions,
    String requiredPermission,
  ) {
    return userPermissions.contains(requiredPermission);
  }
}
