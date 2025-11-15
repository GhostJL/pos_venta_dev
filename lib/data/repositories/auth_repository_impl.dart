
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/domain/repositories/user_repository.dart';


final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

class AuthRepositoryImpl implements AuthRepository, UserRepository {
  final DatabaseHelper _databaseHelper;

  AuthRepositoryImpl(this._databaseHelper);

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<User?> login(String pin) async {
    final db = await _databaseHelper.database;
    final hashedPin = _hashPin(pin);
    final maps = await db.query(
      'users',
      where: 'password_hash = ?',
      whereArgs: [hashedPin],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<User?> getUserById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    return;
  }

  // --- UserRepository Implementation ---

  @override
  Future<void> addUser(User user, {String? password}) async {
    final db = await _databaseHelper.database;
    String? hashedPassword;
    if (password != null) {
      hashedPassword = _hashPin(password);
    }
    
    final userMap = user.copyWith(passwordHash: hashedPassword).toMap();

    await db.insert('users', userMap);
  }

  @override
  Future<User?> getUser(int id) async {
    return getUserById(id);
  }

  @override
  Future<List<User>> getUsers() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
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

  @override
  Future<void> deleteUser(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
