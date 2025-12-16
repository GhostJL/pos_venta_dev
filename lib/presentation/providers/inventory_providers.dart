import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_providers.g.dart';

@riverpod
@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  Stream<List<Inventory>> build() {
    return ref.watch(getAllInventoryProvider).stream();
  }

  Future<void> addInventory(Inventory inventory) async {
    await ref.read(createInventoryProvider).call(inventory);
  }

  Future<void> updateInventory(Inventory inventory) async {
    await ref.read(updateInventoryProvider).call(inventory);
  }

  Future<void> deleteInventory(int id) async {
    await ref.read(deleteInventoryProvider).call(id);
  }

  Future<void> deleteInventoryByVariant(
    int productId,
    int warehouseId,
    int variantId,
  ) async {
    await ref
        .read(deleteInventoryByVariantProvider)
        .call(productId, warehouseId, variantId);
  }
}

@riverpod
Future<List<Inventory>> inventoryByProduct(Ref ref, int productId) {
  return ref.watch(getInventoryByProductProvider).call(productId);
}

@riverpod
Stream<List<Product>> products(Ref ref) {
  return ref.watch(getAllProductsProvider).stream();
}

@riverpod
Future<List<Warehouse>> warehouses(Ref ref) {
  return ref.watch(getAllWarehousesProvider).call();
}
