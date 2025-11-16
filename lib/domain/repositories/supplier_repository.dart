import 'package:myapp/domain/entities/supplier.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> getAllSuppliers();
  Future<Supplier> createSupplier(Supplier supplier);
  Future<Supplier> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(int supplierId);
}
