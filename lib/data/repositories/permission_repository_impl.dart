
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/models/permission_model.dart';
import 'package:myapp/domain/entities/permission.dart';
import 'package:myapp/domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final DatabaseHelper _databaseHelper;

  PermissionRepositoryImpl(this._databaseHelper);

  @override
  Future<void> addPermission(Permission permission) async {
    final db = await _databaseHelper.database;
    final permissionModel = PermissionModel(
      name: permission.name,
      code: permission.code,
      description: permission.description,
      module: permission.module,
      isActive: permission.isActive,
    );
    await db.insert('permissions', permissionModel.toMap());
  }

  @override
  Future<void> deletePermission(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('permissions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Permission?> getPermission(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('permissions', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return PermissionModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<List<Permission>> getPermissions() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('permissions');
    return maps.map((map) => PermissionModel.fromMap(map)).toList();
  }

  @override
  Future<void> updatePermission(Permission permission) async {
    final db = await _databaseHelper.database;
    final permissionModel = PermissionModel(
      id: permission.id,
      name: permission.name,
      code: permission.code,
      description: permission.description,
      module: permission.module,
      isActive: permission.isActive,
    );
    await db.update(
      'permissions',
      permissionModel.toMap(),
      where: 'id = ?',
      whereArgs: [permission.id],
    );
  }
}
