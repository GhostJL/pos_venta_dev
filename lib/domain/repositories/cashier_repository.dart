import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/entities/permission.dart';

abstract class CashierRepository {
  Future<List<User>> getCashiers();
  Future<User?> getCashierById(int id);
  Future<void> createCashier(User cashier, String password);
  Future<void> updateCashier(User cashier);
  Future<void> deleteCashier(int id);
  Future<List<Permission>> getCashierPermissions(int cashierId);
  Future<void> updateCashierPermissions(
    int cashierId,
    List<int> permissionIds,
    int? grantedBy,
  );
}
