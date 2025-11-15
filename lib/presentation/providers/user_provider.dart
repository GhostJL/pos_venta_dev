
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/data/repositories/auth_repository_impl.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/domain/repositories/user_repository.dart';


// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return AuthRepositoryImpl(dbHelper);
});

// Provider to get all users
final allUsersProvider = FutureProvider<List<User>>((ref) {
  return ref.watch(userRepositoryProvider).getUsers();
});

// Provider to add a user
final addUserProvider = FutureProvider.family<void, User>((ref, user) {
  return ref.watch(userRepositoryProvider).addUser(user);
});
