
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/models/user_model.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final DatabaseHelper _databaseHelper;

  UserRepositoryImpl(this._databaseHelper);

  @override
  Future<void> addUser(User user) async {
    final db = await _databaseHelper.database;
    final userModel = UserModel(
      username: user.username,
      email: user.email,
      passwordHash: user.passwordHash,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      phone: user.phone,
      isActive: user.isActive,
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
    await db.insert('users', userModel.toMap());
  }

  @override
  Future<void> deleteUser(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<User?> getUser(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<List<User>> getUsers() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('users');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  @override
  Future<void> updateUser(User user) async {
    final db = await _databaseHelper.database;
    final userModel = UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      passwordHash: user.passwordHash,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      phone: user.phone,
      isActive: user.isActive,
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
    await db.update(
      'users',
      userModel.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
