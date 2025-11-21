import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/user_model.dart';
import 'package:posventa/data/models/permission_model.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/entities/permission.dart';
import 'package:posventa/domain/repositories/cashier_repository.dart';

class CashierRepositoryImpl implements CashierRepository {
  final DatabaseHelper _databaseHelper;

  CashierRepositoryImpl(this._databaseHelper);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<List<User>> getCashiers() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableUsers,
      where: 'role = ?',
      whereArgs: [UserRole.cajero.name],
    );
    return maps.map((map) => UserModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<User?> getCashierById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableUsers,
      where: 'id = ? AND role = ?',
      whereArgs: [id, UserRole.cajero.name],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first).toEntity();
    }
    return null;
  }

  @override
  Future<void> createCashier(User cashier, String password) async {
    final db = await _databaseHelper.database;
    final userModel = UserModel.fromEntity(cashier);
    final map = userModel.toMap();
    map['password_hash'] = _hashPassword(password);
    // Ensure role is cashier
    map['role'] = UserRole.cajero.name;

    await db.insert(DatabaseHelper.tableUsers, map);
  }

  @override
  Future<void> updateCashier(User cashier) async {
    final db = await _databaseHelper.database;
    final userModel = UserModel.fromEntity(cashier);
    final map = userModel.toMap();
    // Don't update password here
    map.remove('password_hash');

    await db.update(
      DatabaseHelper.tableUsers,
      map,
      where: 'id = ?',
      whereArgs: [cashier.id],
    );
  }

  @override
  Future<void> deleteCashier(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Permission>> getCashierPermissions(int cashierId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT p.* FROM ${DatabaseHelper.tablePermissions} p
      INNER JOIN ${DatabaseHelper.tableUserPermissions} up ON p.id = up.permission_id
      WHERE up.user_id = ?
    ''',
      [cashierId],
    );

    return result.map((map) => PermissionModel.fromMap(map)).toList();
  }

  @override
  Future<void> updateCashierPermissions(
    int cashierId,
    List<int> permissionIds,
    int? grantedBy,
  ) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Remove existing permissions
      await txn.delete(
        DatabaseHelper.tableUserPermissions,
        where: 'user_id = ?',
        whereArgs: [cashierId],
      );

      // Add new permissions
      for (final permId in permissionIds) {
        await txn.insert(DatabaseHelper.tableUserPermissions, {
          'user_id': cashierId,
          'permission_id': permId,
          'granted_at': DateTime.now().toIso8601String(),
          'granted_by': grantedBy,
        });
      }
    });
  }
}
