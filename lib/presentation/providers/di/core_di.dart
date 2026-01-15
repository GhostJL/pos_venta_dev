import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';
// DatabaseHelper provider removed

import 'package:posventa/domain/repositories/user_repository.dart';
import 'package:posventa/domain/repositories/auth_repository.dart';
import 'package:posventa/data/repositories/auth_repository_impl.dart';
import 'package:posventa/domain/use_cases/user/get_all_users.dart';
import 'package:posventa/domain/use_cases/user/create_user.dart';
import 'package:posventa/domain/use_cases/user/update_user.dart';
import 'package:posventa/domain/use_cases/user/delete_user.dart';
import 'package:posventa/domain/use_cases/user/has_users_use_case.dart';
import 'package:posventa/domain/repositories/permission_repository.dart';
import 'package:posventa/data/repositories/permission_repository_impl.dart';
import 'package:posventa/domain/repositories/user_permission_repository.dart';
import 'package:posventa/data/repositories/user_permission_repository_impl.dart';
import 'package:posventa/domain/repositories/i_store_repository.dart';
import 'package:posventa/data/repositories/store_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posventa/domain/repositories/settings_repository.dart';
import 'package:posventa/data/repositories/settings_repository_impl.dart';
import 'package:posventa/domain/services/audit_service.dart';
import 'package:posventa/data/services/audit_service_impl.dart';

part 'core_di.g.dart';

@riverpod
AppDatabase appDatabase(ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

@riverpod
Stream<Set<TableUpdate>> tableUpdateStream(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.tableUpdates();
}

@riverpod
Stream<Set<TableUpdate>> debouncedTableUpdateStream(Ref ref) {
  final controller = StreamController<Set<TableUpdate>>();
  Timer? timer;

  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((events) {
      timer?.cancel();
      timer = Timer(const Duration(milliseconds: 800), () {
        if (!controller.isClosed) controller.add(events);
      });
    });
  });

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
}

@riverpod
Future<SharedPreferences> sharedPreferences(ref) =>
    SharedPreferences.getInstance();

@riverpod
Future<SettingsRepository> settingsRepository(ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsRepositoryImpl(prefs);
}

// --- User / Auth Providers ---

@riverpod
UserRepository userRepository(ref) =>
    AuthRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
AuthRepository authRepository(ref) =>
    AuthRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
GetAllUsers getAllUsers(ref) => GetAllUsers(ref.watch(userRepositoryProvider));

@riverpod
CreateUser createUser(ref) => CreateUser(ref.watch(userRepositoryProvider));

@riverpod
UpdateUser updateUser(ref) => UpdateUser(ref.watch(userRepositoryProvider));

@riverpod
DeleteUser deleteUser(ref) => DeleteUser(ref.watch(userRepositoryProvider));

@riverpod
HasUsersUseCase hasUsersUseCase(ref) =>
    HasUsersUseCase(ref.watch(userRepositoryProvider));

// --- Permission Providers ---

@riverpod
PermissionRepository permissionRepository(ref) =>
    PermissionRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
UserPermissionRepository userPermissionRepository(ref) =>
    UserPermissionRepositoryImpl(ref.watch(appDatabaseProvider));

// --- Store Providers ---

@riverpod
IStoreRepository storeRepository(ref) =>
    StoreRepositoryImpl(db: ref.watch(appDatabaseProvider));

@riverpod
AuditService auditService(ref) =>
    AuditServiceImpl(ref.watch(appDatabaseProvider));
