import 'package:posventa/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> addUser(User user, {String? password});
  Future<User?> getUser(int id);
  Future<List<User>> getUsers();
  Future<void> updateUser(User user);
  Future<void> deleteUser(int id);
  Future<bool> hasUsers();
}
