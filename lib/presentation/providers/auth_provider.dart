
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/data/repositories/auth_repository_impl.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/presentation/providers/transaction_provider.dart'; // Import centralized provider
import 'package:shared_preferences/shared_preferences.dart';

// Defines the authentication state of the app
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

// Notifier for authentication logic
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    _loadSession();
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

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return AuthRepositoryImpl(dbHelper);
});

// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

