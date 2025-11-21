import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/entities/permission.dart';
import 'package:posventa/domain/repositories/cashier_repository.dart';
import 'package:posventa/domain/repositories/permission_repository.dart';

class GetCashiersUseCase {
  final CashierRepository repository;

  GetCashiersUseCase(this.repository);

  Future<List<User>> call() {
    return repository.getCashiers();
  }
}

class CreateCashierUseCase {
  final CashierRepository repository;

  CreateCashierUseCase(this.repository);

  Future<void> call(User cashier, String password) {
    return repository.createCashier(cashier, password);
  }
}

class UpdateCashierUseCase {
  final CashierRepository repository;

  UpdateCashierUseCase(this.repository);

  Future<void> call(User cashier) {
    return repository.updateCashier(cashier);
  }
}

class DeleteCashierUseCase {
  final CashierRepository repository;

  DeleteCashierUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteCashier(id);
  }
}

class GetCashierPermissionsUseCase {
  final CashierRepository repository;

  GetCashierPermissionsUseCase(this.repository);

  Future<List<Permission>> call(int cashierId) {
    return repository.getCashierPermissions(cashierId);
  }
}

class UpdateCashierPermissionsUseCase {
  final CashierRepository repository;

  UpdateCashierPermissionsUseCase(this.repository);

  Future<void> call(int cashierId, List<int> permissionIds, int? grantedBy) {
    return repository.updateCashierPermissions(
      cashierId,
      permissionIds,
      grantedBy,
    );
  }
}

class GetAllPermissionsUseCase {
  final PermissionRepository repository;

  GetAllPermissionsUseCase(this.repository);

  Future<List<Permission>> call() {
    return repository.getPermissions();
  }
}
