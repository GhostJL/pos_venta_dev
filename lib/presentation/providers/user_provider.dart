import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<List<User>> build() async {
    return ref.read(getAllUsersProvider).call();
  }

  Future<void> addUser(User user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createUserProvider).call(user);
      return ref.read(getAllUsersProvider).call();
    });
  }

  Future<void> modifyUser(User user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateUserProvider).call(user);
      return ref.read(getAllUsersProvider).call();
    });
  }

  Future<void> removeUser(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteUserProvider).call(id);
      return ref.read(getAllUsersProvider).call();
    });
  }

  Future<void> updatePassword(int userId, String newPassword) async {
    await ref.read(authRepositoryProvider).updatePassword(userId, newPassword);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(getAllUsersProvider).call();
    });
  }
}

@riverpod
Future<User?> currentUser(Ref ref) async {
  // This is a placeholder - you should implement proper session management
  // For now, we'll return the first admin user as a fallback
  final users = await ref.watch(getAllUsersProvider).call();
  return users.isNotEmpty ? users.first : null;
}
