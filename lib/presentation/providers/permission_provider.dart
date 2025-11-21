import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';

final currentUserPermissionsProvider = FutureProvider<List<String>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user == null) {
    return [];
  }

  if (user.role == UserRole.administrador) {
    // Admin has all permissions
    // We return all defined constants to ensure they have access to everything
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
      PermissionConstants.catalogManage,
      PermissionConstants.customerManage,
      PermissionConstants.reportsView,
    ];
  }

  // For cashier, fetch specific permissions
  final permissions = await ref.watch(
    cashierPermissionsProvider(user.id!).future,
  );
  return permissions.map((p) => p.code).toList();
});

// Helper to check if user has a specific permission
// Usage: final hasAccess = ref.watch(hasPermissionProvider(PermissionConstants.posAccess));
final hasPermissionProvider = Provider.family<bool, String>((
  ref,
  permissionCode,
) {
  final permissionsAsync = ref.watch(currentUserPermissionsProvider);

  return permissionsAsync.when(
    data: (permissions) => permissions.contains(permissionCode),
    loading: () => false, // Default to false while loading
    error: (_, __) => false, // Default to false on error
  );
});
