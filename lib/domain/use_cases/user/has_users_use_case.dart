import 'package:posventa/domain/repositories/user_repository.dart';

class HasUsersUseCase {
  final UserRepository _userRepository;

  HasUsersUseCase(this._userRepository);

  Future<bool> call() {
    return _userRepository.hasUsers();
  }
}
