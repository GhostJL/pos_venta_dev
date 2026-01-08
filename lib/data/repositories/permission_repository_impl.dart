import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/entities/permission.dart';
import 'package:posventa/domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final drift_db.AppDatabase db;

  PermissionRepositoryImpl(this.db);

  @override
  Future<void> addPermission(Permission permission) async {
    await db
        .into(db.permissions)
        .insert(
          drift_db.PermissionsCompanion.insert(
            name: permission.name,
            code: permission.code,
            description: Value(permission.description),
            module: permission.module,
            isActive: Value(permission.isActive),
          ),
        );
  }

  @override
  Future<void> deletePermission(int id) async {
    await (db.delete(db.permissions)..where((p) => p.id.equals(id))).go();
  }

  @override
  Future<Permission?> getPermission(int id) async {
    final query = db.select(db.permissions)..where((p) => p.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _mapToPermission(row) : null;
  }

  @override
  Future<List<Permission>> getPermissions() async {
    final rows = await db.select(db.permissions).get();
    return rows.map(_mapToPermission).toList();
  }

  @override
  Future<void> updatePermission(Permission permission) async {
    if (permission.id == null) return;
    await (db.update(
      db.permissions,
    )..where((p) => p.id.equals(permission.id!))).write(
      drift_db.PermissionsCompanion(
        name: Value(permission.name),
        code: Value(permission.code),
        description: Value(permission.description),
        module: Value(permission.module),
        isActive: Value(permission.isActive),
      ),
    );
  }

  Permission _mapToPermission(drift_db.Permission row) {
    return Permission(
      id: row.id,
      name: row.name,
      code: row.code,
      description: row.description,
      module: row.module,
      isActive: row.isActive,
    );
  }
}
