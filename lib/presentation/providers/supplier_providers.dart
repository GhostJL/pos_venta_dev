import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/repositories/supplier_repository.dart';
import 'package:posventa/data/repositories/supplier_repository_impl.dart';
import 'package:posventa/domain/use_cases/supplier/create_supplier.dart';
import 'package:posventa/domain/use_cases/supplier/delete_supplier.dart';
import 'package:posventa/domain/use_cases/supplier/get_all_suppliers.dart';
import 'package:posventa/domain/use_cases/supplier/update_supplier.dart';

part 'supplier_providers.g.dart';

@riverpod
SupplierRepository supplierRepository(ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SupplierRepositoryImpl(dbHelper);
}

@riverpod
GetAllSuppliers getAllSuppliersUseCase(ref) {
  return GetAllSuppliers(ref.watch(supplierRepositoryProvider));
}

@riverpod
CreateSupplier createSupplierUseCase(ref) {
  return CreateSupplier(ref.watch(supplierRepositoryProvider));
}

@riverpod
UpdateSupplier updateSupplierUseCase(ref) {
  return UpdateSupplier(ref.watch(supplierRepositoryProvider));
}

@riverpod
DeleteSupplier deleteSupplierUseCase(ref) {
  return DeleteSupplier(ref.watch(supplierRepositoryProvider));
}

@riverpod
class SupplierList extends _$SupplierList {
  @override
  Future<List<Supplier>> build() async {
    final getAllSuppliers = ref.watch(getAllSuppliersUseCaseProvider);
    return getAllSuppliers();
  }

  Future<void> addSupplier(Supplier supplier) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createSupplierUseCaseProvider).call(supplier);
      return ref.read(getAllSuppliersUseCaseProvider).call();
    });
  }

  Future<void> updateSupplier(Supplier supplier) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateSupplierUseCaseProvider).call(supplier);
      return ref.read(getAllSuppliersUseCaseProvider).call();
    });
  }

  Future<void> deleteSupplier(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteSupplierUseCaseProvider).call(id);
      return ref.read(getAllSuppliersUseCaseProvider).call();
    });
  }
}
