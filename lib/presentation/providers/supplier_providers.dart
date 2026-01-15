import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'supplier_providers.g.dart';

// Providers moved to product_di.dart

@Riverpod(keepAlive: true)
class SupplierList extends _$SupplierList {
  @override
  Future<List<Supplier>> build() async {
    final getAllSuppliers = ref.watch(getAllSuppliersUseCaseProvider);
    return getAllSuppliers();
  }

  Future<Supplier?> addSupplier(Supplier supplier) async {
    state = const AsyncValue.loading();
    Supplier? newSupplier;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) throw "Authenticated user required for audit";

    state = await AsyncValue.guard(() async {
      newSupplier = await ref
          .read(createSupplierUseCaseProvider)
          .call(supplier, userId: userId);
      return ref.read(getAllSuppliersUseCaseProvider).call();
    });
    return newSupplier;
  }

  Future<void> updateSupplier(Supplier supplier) async {
    state = const AsyncValue.loading();
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) throw "Authenticated user required for audit";

    state = await AsyncValue.guard(() async {
      await ref
          .read(updateSupplierUseCaseProvider)
          .call(supplier, userId: userId);
      return ref.read(getAllSuppliersUseCaseProvider).call();
    });
  }

  Future<void> deleteSupplier(int id) async {
    state = const AsyncValue.loading();
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) throw "Authenticated user required for audit";

    state = await AsyncValue.guard(() async {
      await ref.read(deleteSupplierUseCaseProvider).call(id, userId: userId);
      return ref.read(getAllSuppliersUseCaseProvider).call();
    });
  }
}
