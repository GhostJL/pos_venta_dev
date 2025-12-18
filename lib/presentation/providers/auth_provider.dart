import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/repositories/auth_repository.dart';
import 'package:posventa/data/repositories/auth_repository_impl.dart';
import 'package:posventa/presentation/providers/providers.dart';

part 'auth_provider.g.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState._({this.status = AuthStatus.initial, this.user, this.errorMessage});

  factory AuthState.initial() => AuthState._();
  factory AuthState.authenticated(User user) =>
      AuthState._(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      AuthState._(status: AuthStatus.unauthenticated);
  factory AuthState.loading() => AuthState._(status: AuthStatus.loading);
  factory AuthState.error(String message) =>
      AuthState._(status: AuthStatus.error, errorMessage: message);
}

// Provider for AuthRepository
@riverpod
AuthRepository authRepository(Ref ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return AuthRepositoryImpl(dbHelper);
}

// Notifier for authentication logic
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    Future.microtask(() => _loadSession());
    return AuthState.initial();
  }

  Future<void> _loadSession() async {
    state = AuthState.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        final user = await _authRepository.getUserById(userId);
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          // If user from session is not in DB, clear session
          await prefs.remove('user_id');
          state = AuthState.unauthenticated();
        }
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error("Error al cargar la sesión: ${e.toString()}");
    }
  }

  Future<bool> login(String username, String password) async {
    state = AuthState.loading();
    try {
      final user = await _authRepository.login(username, password);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user.id!);
        state = AuthState.authenticated(user);
        return true;
      } else {
        state = AuthState.error("Usuario o contraseña no válidos");
        return false;
      }
    } catch (e) {
      state = AuthState.error("Error al iniciar sesión: ${e.toString()}");
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    await _authRepository.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    state = AuthState.unauthenticated();
  }
}
