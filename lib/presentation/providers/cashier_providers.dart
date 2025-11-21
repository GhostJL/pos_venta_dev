import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/cashier_repository_impl.dart';
import 'package:posventa/data/repositories/permission_repository_impl.dart';
import 'package:posventa/domain/entities/permission.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/repositories/cashier_repository.dart';
import 'package:posventa/domain/repositories/permission_repository.dart';
import 'package:posventa/domain/usecases/cashier/cashier_usecases.dart';

// Repositories
final cashierRepositoryProvider = Provider<CashierRepository>((ref) {
  return CashierRepositoryImpl(DatabaseHelper.instance);
});

final permissionRepositoryProvider = Provider<PermissionRepository>((ref) {
  return PermissionRepositoryImpl(DatabaseHelper.instance);
});

// Use Cases
final getCashiersUseCaseProvider = Provider<GetCashiersUseCase>((ref) {
  return GetCashiersUseCase(ref.watch(cashierRepositoryProvider));
});

final createCashierUseCaseProvider = Provider<CreateCashierUseCase>((ref) {
  return CreateCashierUseCase(ref.watch(cashierRepositoryProvider));
});

final updateCashierUseCaseProvider = Provider<UpdateCashierUseCase>((ref) {
  return UpdateCashierUseCase(ref.watch(cashierRepositoryProvider));
});

final deleteCashierUseCaseProvider = Provider<DeleteCashierUseCase>((ref) {
  return DeleteCashierUseCase(ref.watch(cashierRepositoryProvider));
});

final getCashierPermissionsUseCaseProvider =
    Provider<GetCashierPermissionsUseCase>((ref) {
      return GetCashierPermissionsUseCase(ref.watch(cashierRepositoryProvider));
    });

final updateCashierPermissionsUseCaseProvider =
    Provider<UpdateCashierPermissionsUseCase>((ref) {
      return UpdateCashierPermissionsUseCase(
        ref.watch(cashierRepositoryProvider),
      );
    });

final getAllPermissionsUseCaseProvider = Provider<GetAllPermissionsUseCase>((
  ref,
) {
  return GetAllPermissionsUseCase(ref.watch(permissionRepositoryProvider));
});

// Data Providers
final cashierListProvider = FutureProvider<List<User>>((ref) async {
  final useCase = ref.watch(getCashiersUseCaseProvider);
  return useCase();
});

final allPermissionsProvider = FutureProvider<List<Permission>>((ref) async {
  final useCase = ref.watch(getAllPermissionsUseCaseProvider);
  return useCase();
});

final cashierPermissionsProvider = FutureProvider.family<List<Permission>, int>(
  (ref, cashierId) async {
    final useCase = ref.watch(getCashierPermissionsUseCaseProvider);
    return useCase(cashierId);
  },
);

// Controller for Actions
// Controller for Actions
class CashierController extends AsyncNotifier<void> {
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

  Future<void> updatePermissions(
    int cashierId,
    List<int> permissionIds,
    int? grantedBy,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateCashierPermissionsUseCaseProvider)(
        cashierId,
        permissionIds,
        grantedBy,
      );
      ref.invalidate(cashierPermissionsProvider(cashierId));
    });
  }
}

final cashierControllerProvider =
    AsyncNotifierProvider<CashierController, void>(() {
      return CashierController();
    });
