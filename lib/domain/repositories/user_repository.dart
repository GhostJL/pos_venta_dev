import 'package:myapp/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> addUser(User user);
  Future<User?> getUser(int id);
  Future<List<User>> getUsers();
  Future<void> updateUser(User user);
  Future<void> deleteUser(int id);
}
