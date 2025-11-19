import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/repositories/user_repository.dart';

class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<void> call(User user) async {
    return await repository.addUser(user);
  }
}
