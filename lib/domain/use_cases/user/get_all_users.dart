import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/repositories/user_repository.dart';

class GetAllUsers {
  final UserRepository repository;

  GetAllUsers(this.repository);

  Future<List<User>> call() async {
    return await repository.getUsers();
  }
}
