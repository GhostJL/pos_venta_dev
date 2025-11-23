import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';

part 'permission_provider.g.dart';

@riverpod
Future<List<String>> currentUserPermissions(Ref ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user == null) {
    return [];
  }

  // If user is admin, they have all permissions
  if (user.role == UserRole.administrador) {
    final allPerms = await ref.watch(allPermissionsProvider.future);
    return allPerms.map((p) => p.code).toList();
  } else {
    // Cashier permissions
    if (user.id != null) {
      final perms = await ref.watch(
        cashierPermissionsProvider(user.id!).future,
      );
      return perms.map((p) => p.code).toList();
    }
    return [];
  }
}

// Helper to check if current user has a specific permission
@riverpod
bool hasPermission(Ref ref, String permissionCode) {
  final permissionsAsync = ref.watch(currentUserPermissionsProvider);

  return permissionsAsync.when(
    data: (permissions) => permissions.contains(permissionCode),
    loading: () => false,
    error: (_, __) => false,
  );
}
