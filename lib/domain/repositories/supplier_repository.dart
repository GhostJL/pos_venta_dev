import 'package:posventa/domain/entities/supplier.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> getAllSuppliers({
    String? query,
    int? limit,
    int? offset,
    bool showInactive = false,
  });
  Future<int> countSuppliers({String? query, bool showInactive = false});
  Future<Supplier> createSupplier(Supplier supplier);
  Future<Supplier> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(int supplierId);
  Future<bool> isCodeUnique(String code, {int? excludeId});
}
