import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/data/repositories/cashier_repository_impl.dart';
import 'package:posventa/data/repositories/permission_repository_impl.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:posventa/domain/entities/permission.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/repositories/cashier_repository.dart';
import 'package:posventa/domain/repositories/permission_repository.dart';
import 'package:posventa/domain/use_cases/cashier/cashier_usecases.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

part 'cashier_providers.g.dart';

// Repositories
@riverpod
CashierRepository cashierRepository(Ref ref) {
  return CashierRepositoryImpl(ref.watch(appDatabaseProvider));
}

@riverpod
PermissionRepository permissionRepository(Ref ref) {
  return PermissionRepositoryImpl(ref.watch(appDatabaseProvider));
}

// Use Cases
@riverpod
GetCashiersUseCase getCashiersUseCase(Ref ref) {
  return GetCashiersUseCase(ref.watch(cashierRepositoryProvider));
}

@riverpod
CreateCashierUseCase createCashierUseCase(Ref ref) {
  return CreateCashierUseCase(ref.watch(cashierRepositoryProvider));
}

@riverpod
UpdateCashierUseCase updateCashierUseCase(Ref ref) {
  return UpdateCashierUseCase(ref.watch(cashierRepositoryProvider));
}

@riverpod
DeleteCashierUseCase deleteCashierUseCase(Ref ref) {
  return DeleteCashierUseCase(ref.watch(cashierRepositoryProvider));
}

@riverpod
GetCashierPermissionsUseCase getCashierPermissionsUseCase(Ref ref) {
  return GetCashierPermissionsUseCase(ref.watch(cashierRepositoryProvider));
}

@riverpod
UpdateCashierPermissionsUseCase updateCashierPermissionsUseCase(Ref ref) {
  return UpdateCashierPermissionsUseCase(ref.watch(cashierRepositoryProvider));
}

@riverpod
GetAllPermissionsUseCase getAllPermissionsUseCase(Ref ref) {
  return GetAllPermissionsUseCase(ref.watch(permissionRepositoryProvider));
}

// Data Providers
@riverpod
Future<List<User>> cashierList(Ref ref) async {
  final useCase = ref.watch(getCashiersUseCaseProvider);
  return useCase();
}

@riverpod
Future<List<Permission>> allPermissions(Ref ref) async {
  final useCase = ref.watch(getAllPermissionsUseCaseProvider);
  return useCase();
}

@riverpod
Future<List<Permission>> cashierPermissions(Ref ref, int cashierId) async {
  final useCase = ref.watch(getCashierPermissionsUseCaseProvider);
  return useCase(cashierId);
}

// Controller for Actions
@riverpod
class CashierController extends _$CashierController {
  @override
  Future<void> build() async {
    // Initial state
    return;
  }

  Future<void> createCashier(User cashier, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createCashierUseCaseProvider)(cashier, password);
      ref.invalidate(cashierListProvider);
    });
  }

  Future<void> updateCashier(User cashier) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateCashierUseCaseProvider)(cashier);
      ref.invalidate(cashierListProvider);
    });
  }

  Future<void> deleteCashier(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteCashierUseCaseProvider)(id);
      ref.invalidate(cashierListProvider);
    });
  }

  Future<void> updatePermissions(int cashierId, List<int> permissionIds) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = ref.read(authProvider).user;
      await ref.read(updateCashierPermissionsUseCaseProvider)(
        cashierId,
        permissionIds,
        currentUser?.id,
      );
      ref.invalidate(cashierPermissionsProvider(cashierId));
    });
  }
}
