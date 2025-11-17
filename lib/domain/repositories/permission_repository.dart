import 'package:posventa/domain/entities/permission.dart';

abstract class PermissionRepository {
  Future<void> addPermission(Permission permission);
  Future<Permission?> getPermission(int id);
  Future<List<Permission>> getPermissions();
  Future<void> updatePermission(Permission permission);
  Future<void> deletePermission(int id);
}
