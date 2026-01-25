import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_providers.g.dart';

@Riverpod(keepAlive: true)
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

  Future<void> adjustInventory(InventoryMovement movement) async {
    await ref.read(adjustInventoryUseCaseProvider).call(movement);
    // Refresh to show new stock
    ref.invalidateSelf();
    ref.invalidate(inventoryByProductProvider(movement.productId));
  }
}

@riverpod
Future<List<Inventory>> inventoryByProduct(Ref ref, int productId) {
  return ref.watch(getInventoryByProductProvider).call(productId);
}

@riverpod
Future<List<Product>> products(Ref ref) async {
  final result = await ref.watch(getAllProductsProvider).call();
  return result.fold(
    (failure) => throw failure.message,
    (products) => products,
  );
}

@Riverpod(keepAlive: true)
Future<List<Warehouse>> warehouses(Ref ref) {
  return ref.watch(getAllWarehousesProvider).call();
}
