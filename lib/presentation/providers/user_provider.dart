import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/data/repositories/auth_repository_impl.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/domain/repositories/user_repository.dart';
import 'package:myapp/presentation/providers/transaction_provider.dart';

// Proveedor para UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return AuthRepositoryImpl(dbHelper);
});

// Proveedor para obtener todos los usuarios
final allUsersProvider = FutureProvider<List<User>>((ref) {
  return ref.watch(userRepositoryProvider).getUsers();
});

// Proveedor para agregar un usuario
final addUserProvider = FutureProvider.family<void, User>((ref, user) {
  return ref.watch(userRepositoryProvider).addUser(user);
});
