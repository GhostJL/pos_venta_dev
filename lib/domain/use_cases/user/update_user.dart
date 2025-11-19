import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/repositories/user_repository.dart';

class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<void> call(User user) async {
    return await repository.updateUser(user);
  }
}
