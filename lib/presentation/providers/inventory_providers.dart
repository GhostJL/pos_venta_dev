import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_providers.g.dart';

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  Future<List<Inventory>> build() async {
    return ref.read(getAllInventoryProvider).call();
  }

  Future<void> addInventory(Inventory inventory) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createInventoryProvider).call(inventory);
      return ref.read(getAllInventoryProvider).call();
    });
  }

  Future<void> updateInventory(Inventory inventory) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateInventoryProvider).call(inventory);
      return ref.read(getAllInventoryProvider).call();
    });
  }

  Future<void> deleteInventory(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteInventoryProvider).call(id);
      return ref.read(getAllInventoryProvider).call();
    });
  }
}

@riverpod
Future<List<Inventory>> inventoryByProduct(Ref ref, int productId) {
  return ref.watch(getInventoryByProductProvider).call(productId);
}

@riverpod
Future<List<Product>> products(Ref ref) {
  return ref.watch(getAllProductsProvider).call();
}

@riverpod
Future<List<Warehouse>> warehouses(Ref ref) {
  return ref.watch(getAllWarehousesProvider).call();
}
