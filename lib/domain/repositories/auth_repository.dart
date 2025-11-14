import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/models/user_model.dart';
import 'package:myapp/domain/entities/user.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper;

  AuthRepository(this._databaseHelper);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signIn(String username, String password) async {
    final db = await _databaseHelper.database;
    final hashedPassword = _hashPassword(password);
    final maps = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, hashedPassword],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<User?> signUp(User user, String password) async {
    final db = await _databaseHelper.database;
    final hashedPassword = _hashPassword(password);
    final userModel = UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      passwordHash: hashedPassword,
      firstName: user.firstName,
      lastName: user.lastName,
      role: UserRole.admin, // Assign admin role directly
      phone: user.phone,
      isActive: user.isActive,
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );

    try {
      final id = await db.insert('users', userModel.toMap());
      await _grantAllPermissions(id);
      return user.copyWith(id: id, role: UserRole.admin);
    } catch (e) {
      // Handle unique constraint violations or other errors
      return null;
    }
  }

  Future<void> _grantAllPermissions(int userId) async {
    final db = await _databaseHelper.database;
    final permissions = await db.query('permissions');
    final batch = db.batch();
    for (final permission in permissions) {
      batch.insert('user_permissions', {
        'user_id': userId,
        'permission_id': permission['id'],
      });
    }
    await batch.commit(noResult: true);
  }
}
