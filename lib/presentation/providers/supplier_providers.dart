import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/supplier_repository_impl.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/repositories/supplier_repository.dart';
import 'package:posventa/domain/use_cases/create_supplier.dart';
import 'package:posventa/domain/use_cases/delete_supplier.dart';
import 'package:posventa/domain/use_cases/get_all_suppliers.dart';
import 'package:posventa/domain/use_cases/update_supplier.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SupplierRepositoryImpl(dbHelper);
});

final getAllSuppliersUseCaseProvider = Provider(
  (ref) => GetAllSuppliers(ref.watch(supplierRepositoryProvider)),
);

final createSupplierUseCaseProvider = Provider(
  (ref) => CreateSupplier(ref.watch(supplierRepositoryProvider)),
);

final updateSupplierUseCaseProvider = Provider(
  (ref) => UpdateSupplier(ref.watch(supplierRepositoryProvider)),
);

final deleteSupplierUseCaseProvider = Provider(
  (ref) => DeleteSupplier(ref.watch(supplierRepositoryProvider)),
);

class SupplierListNotifier extends StateNotifier<AsyncValue<List<Supplier>>> {
  final GetAllSuppliers _getAllSuppliers;
  final CreateSupplier _createSupplier;
  final UpdateSupplier _updateSupplier;
  final DeleteSupplier _deleteSupplier;

  SupplierListNotifier(
    this._getAllSuppliers,
    this._createSupplier,
    this._updateSupplier,
    this._deleteSupplier,
  ) : super(const AsyncValue.loading()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    state = const AsyncValue.loading();
    try {
      final suppliers = await _getAllSuppliers();
      state = AsyncValue.data(suppliers);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _createSupplier(supplier);
    } finally {
      await loadSuppliers();
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await _updateSupplier(supplier);
    } finally {
      await loadSuppliers();
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await _deleteSupplier(id);
    } finally {
      await loadSuppliers();
    }
  }
}

final supplierListProvider =
    StateNotifierProvider<SupplierListNotifier, AsyncValue<List<Supplier>>>(
  (ref) {
    return SupplierListNotifier(
      ref.watch(getAllSuppliersUseCaseProvider),
      ref.watch(createSupplierUseCaseProvider),
      ref.watch(updateSupplierUseCaseProvider),
      ref.watch(deleteSupplierUseCaseProvider),
    );
  },
);
