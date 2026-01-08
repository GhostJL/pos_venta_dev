import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/entities/user_permission.dart';
import 'package:posventa/domain/repositories/user_permission_repository.dart';

class UserPermissionRepositoryImpl implements UserPermissionRepository {
  final drift_db.AppDatabase db;

  UserPermissionRepositoryImpl(this.db);

  @override
  Future<void> addUserPermission(UserPermission userPermission) async {
    await db
        .into(db.userPermissions)
        .insert(
          drift_db.UserPermissionsCompanion.insert(
            userId: userPermission.userId,
            permissionId: userPermission.permissionId,
            grantedAt: userPermission.grantedAt,
            grantedBy: Value(userPermission.grantedBy),
          ),
        );
  }

  @override
  Future<void> deleteUserPermission(int userId, int permissionId) async {
    await (db.delete(db.userPermissions)..where(
          (t) => t.userId.equals(userId) & t.permissionId.equals(permissionId),
        ))
        .go();
  }

  @override
  Future<List<UserPermission>> getUserPermissions(int userId) async {
    final query = db.select(db.userPermissions)
      ..where((t) => t.userId.equals(userId));
    final rows = await query.get();
    return rows.map(_mapToUserPermission).toList();
  }

  UserPermission _mapToUserPermission(drift_db.UserPermission row) {
    return UserPermission(
      id: row.id,
      userId: row.userId,
      permissionId: row.permissionId,
      grantedAt: row.grantedAt,
      grantedBy: row.grantedBy,
    );
  }
}
