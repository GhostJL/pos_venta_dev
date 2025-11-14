
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/data/datasources/database_helper.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dbHelper = DatabaseHelper();
  return AuthRepository(dbHelper);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(null);

  Future<void> signIn(String username, String password) async {
    final user = await _authRepository.signIn(username, password);
    state = user;
  }

  Future<bool> signUp(User user, String password) async {
    final createdUser = await _authRepository.signUp(user, password);
    if (createdUser != null) {
      state = createdUser;
      return true;
    }
    return false;
  }

  void signOut() {
    state = null;
  }
}
