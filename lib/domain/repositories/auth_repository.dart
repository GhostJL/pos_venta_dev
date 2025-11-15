import 'package:myapp/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> login(String pin);
  Future<User?> getUserById(int id);
  Future<void> logout();
}
