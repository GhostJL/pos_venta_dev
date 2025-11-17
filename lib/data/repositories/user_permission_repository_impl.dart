import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/user_permission_model.dart';
import 'package:posventa/domain/entities/user_permission.dart';
import 'package:posventa/domain/repositories/user_permission_repository.dart';

class UserPermissionRepositoryImpl implements UserPermissionRepository {
  final DatabaseHelper _databaseHelper;

  UserPermissionRepositoryImpl(this._databaseHelper);

  @override
  Future<void> addUserPermission(UserPermission userPermission) async {
    final db = await _databaseHelper.database;
    final userPermissionModel = UserPermissionModel(
      userId: userPermission.userId,
      permissionId: userPermission.permissionId,
      grantedAt: userPermission.grantedAt,
      grantedBy: userPermission.grantedBy,
    );
    await db.insert('user_permissions', userPermissionModel.toMap());
  }

  @override
  Future<void> deleteUserPermission(int userId, int permissionId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'user_permissions',
      where: 'user_id = ? AND permission_id = ?',
      whereArgs: [userId, permissionId],
    );
  }

  @override
  Future<List<UserPermission>> getUserPermissions(int userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'user_permissions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => UserPermissionModel.fromMap(map)).toList();
  }
}
