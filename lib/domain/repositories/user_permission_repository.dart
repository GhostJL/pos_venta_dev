import 'package:myapp/domain/entities/user_permission.dart';

abstract class UserPermissionRepository {
  Future<void> addUserPermission(UserPermission userPermission);
  Future<List<UserPermission>> getUserPermissions(int userId);
  Future<void> deleteUserPermission(int userId, int permissionId);
}
