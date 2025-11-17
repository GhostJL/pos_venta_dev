import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/domain/repositories/user_repository.dart';

class AuthRepositoryImpl implements AuthRepository, UserRepository {
  final DatabaseHelper _databaseHelper;

  AuthRepositoryImpl(this._databaseHelper);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<User?> login(String username, String password) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      // Corrected column name from 'password' to 'password_hash'
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, _hashPassword(password)],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    return Future.value();
  }

  @override
  Future<User?> getUserById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> addUser(User user, {String? password}) async {
    if (password == null || password.isEmpty) {
      throw ArgumentError(
        'La contraseña no puede ser nula ni estar vacía para un usuario nuevo.',
      );
    }
    final db = await _databaseHelper.database;
    final hashedPassword = _hashPassword(password);

    final userMap = user.toMap();
    userMap['password_hash'] = hashedPassword;

    await db.insert('users', userMap);
  }

  @override
  Future<void> deleteUser(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<User?> getUser(int id) {
    return getUserById(id);
  }

  @override
  Future<List<User>> getUsers() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<List<User>> getCashiers() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [UserRole.cajero.name],
    );

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  @override
  Future<void> updateUser(User user) async {
    final db = await _databaseHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
