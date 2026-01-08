import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/repositories/auth_repository.dart';
import 'package:posventa/domain/repositories/user_repository.dart';

class AuthRepositoryImpl implements AuthRepository, UserRepository {
  final drift_db.AppDatabase db;

  AuthRepositoryImpl(this.db);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<User?> login(String username, String password) async {
    final hashedPassword = _hashPassword(password);
    final query = db.select(db.users)
      ..where(
        (u) =>
            u.username.equals(username) & u.passwordHash.equals(hashedPassword),
      );

    final userRow = await query.getSingleOrNull();

    if (userRow != null) {
      return _mapToUser(userRow);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    return Future.value();
  }

  @override
  Future<User?> getUserById(int id) async {
    final query = db.select(db.users)..where((u) => u.id.equals(id));
    final userRow = await query.getSingleOrNull();
    return userRow != null ? _mapToUser(userRow) : null;
  }

  @override
  Future<void> addUser(User user, {String? password}) async {
    if (password == null || password.isEmpty) {
      throw ArgumentError(
        'La contraseña no puede ser nula ni estar vacía para un usuario nuevo.',
      );
    }
    final hashedPassword = _hashPassword(password);

    await db
        .into(db.users)
        .insert(
          drift_db.UsersCompanion.insert(
            username: user.username,
            passwordHash: hashedPassword,
            firstName: Value(user.firstName),
            lastName: Value(user.lastName),
            email: Value(user.email),
            role: user.role.name,
            isActive: Value(user.isActive),
            onboardingCompleted: Value(user.onboardingCompleted),
            lastLoginAt: Value(user.lastLoginAt),
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
          ),
        );
  }

  @override
  Future<void> deleteUser(int id) async {
    await (db.delete(db.users)..where((u) => u.id.equals(id))).go();
  }

  @override
  Future<User?> getUser(int id) {
    return getUserById(id);
  }

  @override
  Future<List<User>> getUsers() async {
    final userRows = await db.select(db.users).get();
    return userRows.map(_mapToUser).toList();
  }

  Future<List<User>> getCashiers() async {
    final query = db.select(db.users)
      ..where((u) => u.role.equals(UserRole.cajero.name));
    final userRows = await query.get();
    return userRows.map(_mapToUser).toList();
  }

  @override
  Future<void> updateUser(User user) async {
    await (db.update(db.users)..where((u) => u.id.equals(user.id!))).write(
      drift_db.UsersCompanion(
        username: Value(user.username),
        firstName: Value(user.firstName),
        lastName: Value(user.lastName),
        email: Value(user.email),
        role: Value(user.role.name),
        isActive: Value(user.isActive),
        onboardingCompleted: Value(user.onboardingCompleted),
        lastLoginAt: Value(user.lastLoginAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<bool> hasUsers() async {
    final countFunc = db.users.id.count();
    final query = db.selectOnly(db.users)..addColumns([countFunc]);
    final result = await query.getSingle();
    final count = result.read(countFunc);
    return (count ?? 0) > 0;
  }

  User _mapToUser(drift_db.User row) {
    return User(
      id: row.id,
      username: row.username,
      firstName: row.firstName ?? '',
      lastName: row.lastName ?? '',
      email: row.email,
      role: UserRole.values.firstWhere(
        (e) => e.name == row.role,
        orElse: () => UserRole.administrador,
      ),
      isActive: row.isActive,
      onboardingCompleted: row.onboardingCompleted,
      lastLoginAt: row.lastLoginAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
