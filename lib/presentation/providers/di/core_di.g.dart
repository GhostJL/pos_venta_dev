// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
const appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  const AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'c675127bc622bd2a1013b8fd2ffb93b2ee78ce93';

@ProviderFor(tableUpdateStream)
const tableUpdateStreamProvider = TableUpdateStreamProvider._();

final class TableUpdateStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<TableUpdate>>,
          Set<TableUpdate>,
          Stream<Set<TableUpdate>>
        >
    with $FutureModifier<Set<TableUpdate>>, $StreamProvider<Set<TableUpdate>> {
  const TableUpdateStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tableUpdateStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tableUpdateStreamHash();

  @$internal
  @override
  $StreamProviderElement<Set<TableUpdate>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<TableUpdate>> create(Ref ref) {
    return tableUpdateStream(ref);
  }
}

String _$tableUpdateStreamHash() => r'9767c1f9cfea0e50fa322b91308d170f5ae90d0c';

@ProviderFor(debouncedTableUpdateStream)
const debouncedTableUpdateStreamProvider =
    DebouncedTableUpdateStreamProvider._();

final class DebouncedTableUpdateStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<TableUpdate>>,
          Set<TableUpdate>,
          Stream<Set<TableUpdate>>
        >
    with $FutureModifier<Set<TableUpdate>>, $StreamProvider<Set<TableUpdate>> {
  const DebouncedTableUpdateStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debouncedTableUpdateStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debouncedTableUpdateStreamHash();

  @$internal
  @override
  $StreamProviderElement<Set<TableUpdate>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<TableUpdate>> create(Ref ref) {
    return debouncedTableUpdateStream(ref);
  }
}

String _$debouncedTableUpdateStreamHash() =>
    r'af833ef8b8f70a5ad3fe5cd6ef6e871b40dda813';

@ProviderFor(sharedPreferences)
const sharedPreferencesProvider = SharedPreferencesProvider._();

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  const SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'1cb46d6bb5f6c7badabd3ab1dcb5d1552aa4aa09';

@ProviderFor(settingsRepository)
const settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsRepository>,
          SettingsRepository,
          FutureOr<SettingsRepository>
        >
    with
        $FutureModifier<SettingsRepository>,
        $FutureProvider<SettingsRepository> {
  const SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsRepository> create(Ref ref) {
    return settingsRepository(ref);
  }
}

String _$settingsRepositoryHash() =>
    r'26f2e22b821804ccdc5d4e56857e27c1d6040c2f';

@ProviderFor(userRepository)
const userRepositoryProvider = UserRepositoryProvider._();

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  const UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'42d18dc5b411d6ce17a1806e6a99bfdd3dae7dff';

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'6584ecec932bdef193ff8ba96a4dbaa3b77d5fc2';

@ProviderFor(getAllUsers)
const getAllUsersProvider = GetAllUsersProvider._();

final class GetAllUsersProvider
    extends $FunctionalProvider<GetAllUsers, GetAllUsers, GetAllUsers>
    with $Provider<GetAllUsers> {
  const GetAllUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllUsersHash();

  @$internal
  @override
  $ProviderElement<GetAllUsers> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllUsers create(Ref ref) {
    return getAllUsers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllUsers value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllUsers>(value),
    );
  }
}

String _$getAllUsersHash() => r'b305a9a9ca0f8d24052387567486e00ecd04fafe';

@ProviderFor(createUser)
const createUserProvider = CreateUserProvider._();

final class CreateUserProvider
    extends $FunctionalProvider<CreateUser, CreateUser, CreateUser>
    with $Provider<CreateUser> {
  const CreateUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createUserHash();

  @$internal
  @override
  $ProviderElement<CreateUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateUser create(Ref ref) {
    return createUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateUser>(value),
    );
  }
}

String _$createUserHash() => r'165a6032bcf8510db7f794aa287d2c6b35c810c8';

@ProviderFor(updateUser)
const updateUserProvider = UpdateUserProvider._();

final class UpdateUserProvider
    extends $FunctionalProvider<UpdateUser, UpdateUser, UpdateUser>
    with $Provider<UpdateUser> {
  const UpdateUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateUserHash();

  @$internal
  @override
  $ProviderElement<UpdateUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateUser create(Ref ref) {
    return updateUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateUser>(value),
    );
  }
}

String _$updateUserHash() => r'662689f7e09c3417995a673e8b5ab2ec9d2ac4b2';

@ProviderFor(deleteUser)
const deleteUserProvider = DeleteUserProvider._();

final class DeleteUserProvider
    extends $FunctionalProvider<DeleteUser, DeleteUser, DeleteUser>
    with $Provider<DeleteUser> {
  const DeleteUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteUserHash();

  @$internal
  @override
  $ProviderElement<DeleteUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteUser create(Ref ref) {
    return deleteUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteUser>(value),
    );
  }
}

String _$deleteUserHash() => r'75ab4530a0645fe2c2ac76bc69aa750a11d1259b';

@ProviderFor(hasUsersUseCase)
const hasUsersUseCaseProvider = HasUsersUseCaseProvider._();

final class HasUsersUseCaseProvider
    extends
        $FunctionalProvider<HasUsersUseCase, HasUsersUseCase, HasUsersUseCase>
    with $Provider<HasUsersUseCase> {
  const HasUsersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasUsersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasUsersUseCaseHash();

  @$internal
  @override
  $ProviderElement<HasUsersUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HasUsersUseCase create(Ref ref) {
    return hasUsersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HasUsersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HasUsersUseCase>(value),
    );
  }
}

String _$hasUsersUseCaseHash() => r'207dd61e8ac2406bdd7ca4ad578e88a6e3e01190';

@ProviderFor(permissionRepository)
const permissionRepositoryProvider = PermissionRepositoryProvider._();

final class PermissionRepositoryProvider
    extends
        $FunctionalProvider<
          PermissionRepository,
          PermissionRepository,
          PermissionRepository
        >
    with $Provider<PermissionRepository> {
  const PermissionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PermissionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionRepository create(Ref ref) {
    return permissionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionRepository>(value),
    );
  }
}

String _$permissionRepositoryHash() =>
    r'8ab7d4c1aa4a515ad299818c191abe314830c2bd';

@ProviderFor(userPermissionRepository)
const userPermissionRepositoryProvider = UserPermissionRepositoryProvider._();

final class UserPermissionRepositoryProvider
    extends
        $FunctionalProvider<
          UserPermissionRepository,
          UserPermissionRepository,
          UserPermissionRepository
        >
    with $Provider<UserPermissionRepository> {
  const UserPermissionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPermissionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPermissionRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserPermissionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserPermissionRepository create(Ref ref) {
    return userPermissionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPermissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPermissionRepository>(value),
    );
  }
}

String _$userPermissionRepositoryHash() =>
    r'0aa9a84a7499d4fb9232fa295c46a3d698cac70a';

@ProviderFor(storeRepository)
const storeRepositoryProvider = StoreRepositoryProvider._();

final class StoreRepositoryProvider
    extends
        $FunctionalProvider<
          IStoreRepository,
          IStoreRepository,
          IStoreRepository
        >
    with $Provider<IStoreRepository> {
  const StoreRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeRepositoryHash();

  @$internal
  @override
  $ProviderElement<IStoreRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IStoreRepository create(Ref ref) {
    return storeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IStoreRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IStoreRepository>(value),
    );
  }
}

String _$storeRepositoryHash() => r'50df64263cafa4dc858f1d86730544d6fd7f0551';

@ProviderFor(auditService)
const auditServiceProvider = AuditServiceProvider._();

final class AuditServiceProvider
    extends $FunctionalProvider<AuditService, AuditService, AuditService>
    with $Provider<AuditService> {
  const AuditServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditServiceHash();

  @$internal
  @override
  $ProviderElement<AuditService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuditService create(Ref ref) {
    return auditService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuditService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuditService>(value),
    );
  }
}

String _$auditServiceHash() => r'57e507b9cf903bef6e1802f621bf4710dec190a7';
