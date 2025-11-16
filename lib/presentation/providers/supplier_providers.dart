import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/repositories/supplier_repository_impl.dart';
import 'package:myapp/domain/entities/supplier.dart';
import 'package:myapp/domain/repositories/supplier_repository.dart';
import 'package:myapp/domain/use_cases/create_supplier.dart';
import 'package:myapp/domain/use_cases/delete_supplier.dart';
import 'package:myapp/domain/use_cases/get_all_suppliers.dart';
import 'package:myapp/domain/use_cases/update_supplier.dart';

// 1. Repositorio
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepositoryImpl(DatabaseHelper.instance);
});

// 2. Casos de Uso
final getAllSuppliersProvider = Provider((ref) {
  return GetAllSuppliers(ref.watch(supplierRepositoryProvider));
});

final createSupplierProvider = Provider((ref) {
  return CreateSupplier(ref.watch(supplierRepositoryProvider));
});

final updateSupplierProvider = Provider((ref) {
  return UpdateSupplier(ref.watch(supplierRepositoryProvider));
});

final deleteSupplierProvider = Provider((ref) {
  return DeleteSupplier(ref.watch(supplierRepositoryProvider));
});

// 3. State Notifier para la lista de proveedores
final supplierListProvider = StateNotifierProvider<SupplierListNotifier, List<Supplier>>((ref) {
  return SupplierListNotifier(ref);
});

class SupplierListNotifier extends StateNotifier<List<Supplier>> {
  final Ref _ref;

  SupplierListNotifier(this._ref) : super([]) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    final getAllSuppliers = _ref.read(getAllSuppliersProvider);
    state = await getAllSuppliers();
  }

  Future<void> addSupplier(Supplier supplier) async {
    final createSupplier = _ref.read(createSupplierProvider);
    final newSupplier = await createSupplier(supplier);
    state = [...state, newSupplier];
  }

  Future<void> editSupplier(Supplier supplier) async {
    final updateSupplier = _ref.read(updateSupplierProvider);
    final updatedSupplier = await updateSupplier(supplier);
    state = [
      for (final s in state)
        if (s.id == updatedSupplier.id) updatedSupplier else s,
    ];
  }

  Future<void> removeSupplier(int supplierId) async {
    final deleteSupplier = _ref.read(deleteSupplierProvider);
    await deleteSupplier(supplierId);
    state = state.where((s) => s.id != supplierId).toList();
  }
}
