import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/entities/permission.dart';
import 'package:posventa/domain/repositories/cashier_repository.dart';
import 'package:posventa/core/constants/permission_constants.dart';

class CashierRepositoryImpl implements CashierRepository {
  final drift_db.AppDatabase db;

  CashierRepositoryImpl(this.db);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  User _mapRowToEntity(drift_db.User row) {
    return User(
      id: row.id,
      username: row.username,
      firstName: row.firstName ?? '',
      lastName: row.lastName ?? '',
      email: row.email,
      role: UserRole.values.firstWhere(
        (e) => e.name == row.role,
        orElse: () => UserRole.cajero,
      ),
      isActive: row.isActive,
      onboardingCompleted: row.onboardingCompleted,
      lastLoginAt: row.lastLoginAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Permission _mapPermissionRowToEntity(drift_db.Permission row) {
    return Permission(
      id: row.id,
      name: row.name,
      code: row.code,
      description: row.description,
      module: row.module,
      isActive: row.isActive,
    );
  }

  @override
  Future<List<User>> getCashiers() async {
    final query = db.select(db.users)
      ..where((u) => u.role.equals(UserRole.cajero.name));
    final rows = await query.get();
    return rows.map(_mapRowToEntity).toList();
  }

  @override
  Future<User?> getCashierById(int id) async {
    final query = db.select(db.users)
      ..where((u) => u.id.equals(id) & u.role.equals(UserRole.cajero.name));
    final row = await query.getSingleOrNull();
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<void> createCashier(User cashier, String password) async {
    final hashedPassword = _hashPassword(password);

    await db.transaction(() async {
      // 1. Insert User
      final userId = await db
          .into(db.users)
          .insert(
            drift_db.UsersCompanion.insert(
              username: cashier.username,
              passwordHash: hashedPassword,
              firstName: Value(cashier.firstName),
              lastName: Value(cashier.lastName),
              email: Value(cashier.email),
              role: UserRole.cajero.name, // Ensure role is cashier
              isActive: Value(cashier.isActive),
              onboardingCompleted: Value(cashier.onboardingCompleted),
              lastLoginAt: Value(cashier.lastLoginAt),
              createdAt: cashier.createdAt,
              updatedAt: cashier.updatedAt,
            ),
          );

      // 2. Assign Default Permissions
      // Get IDs for default permissions
      final permissionQuery = db.select(db.permissions)
        ..where(
          (p) => p.code.isIn(PermissionConstants.defaultCashierPermissions),
        );
      final defaultPermissions = await permissionQuery.get();

      // Insert UserPermissions
      for (final perm in defaultPermissions) {
        await db
            .into(db.userPermissions)
            .insert(
              drift_db.UserPermissionsCompanion.insert(
                userId: userId,
                permissionId: perm.id,
                grantedAt: DateTime.now(),
                // grantedBy is null as it's system assigned
              ),
            );
      }
    });
  }

  @override
  Future<void> updateCashier(User cashier) async {
    if (cashier.id == null) return;

    // Don't update password here
    // Create companion but exclude passwordHash unless you want to update it (AuthRepository might handle password change separately)
    // The original implementation didn't update password here.

    await (db.update(db.users)..where((u) => u.id.equals(cashier.id!))).write(
      drift_db.UsersCompanion(
        username: Value(cashier.username),
        firstName: Value(cashier.firstName),
        lastName: Value(cashier.lastName),
        email: Value(cashier.email),
        role: Value(UserRole.cajero.name),
        isActive: Value(cashier.isActive),
        onboardingCompleted: Value(cashier.onboardingCompleted),
        lastLoginAt: Value(cashier.lastLoginAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteCashier(int id) async {
    await (db.delete(db.users)..where((u) => u.id.equals(id))).go();
  }

  @override
  Future<List<Permission>> getCashierPermissions(int cashierId) async {
    final query = db.select(db.permissions).join([
      innerJoin(
        db.userPermissions,
        db.userPermissions.permissionId.equalsExp(db.permissions.id),
      ),
    ])..where(db.userPermissions.userId.equals(cashierId));

    final rows = await query.get();

    return rows.map((row) {
      final permission = row.readTable(db.permissions);
      return _mapPermissionRowToEntity(permission);
    }).toList();
  }

  @override
  Future<void> updateCashierPermissions(
    int cashierId,
    List<int> permissionIds,
    int? grantedBy,
  ) async {
    await db.transaction(() async {
      // Remove existing permissions
      await (db.delete(
        db.userPermissions,
      )..where((t) => t.userId.equals(cashierId))).go();

      // Add new permissions
      for (final permId in permissionIds) {
        await db
            .into(db.userPermissions)
            .insert(
              drift_db.UserPermissionsCompanion.insert(
                userId: cashierId,
                permissionId: permId,
                grantedAt: DateTime.now(),
                grantedBy: Value(grantedBy),
              ),
            );
      }
    });
  }
}
