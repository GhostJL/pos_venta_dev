import 'package:posventa/domain/entities/supplier.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> getAllSuppliers({
    String? query,
    int? limit,
    int? offset,
    bool showInactive = false,
  });
  Future<int> countSuppliers({String? query, bool showInactive = false});
  Future<Supplier> createSupplier(Supplier supplier, {required int userId});
  Future<Supplier> updateSupplier(Supplier supplier, {required int userId});
  Future<void> deleteSupplier(int supplierId, {required int userId});
  Future<bool> isCodeUnique(String code, {int? excludeId});
}
