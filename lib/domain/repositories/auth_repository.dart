import 'package:posventa/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> login(String username, String password);
  Future<void> logout();
  Future<User?> getUserById(int id);
}
