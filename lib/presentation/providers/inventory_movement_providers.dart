import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_movement_providers.g.dart';

@riverpod
class InventoryMovementNotifier extends _$InventoryMovementNotifier {
  @override
  Future<List<InventoryMovement>> build() async {
    return ref.read(getAllInventoryMovementsProvider).call();
  }

  Future<void> addMovement(InventoryMovement movement) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createInventoryMovementProvider).call(movement);
      return ref.read(getAllInventoryMovementsProvider).call();
    });
  }

  Future<void> modifyMovement(InventoryMovement movement) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateInventoryMovementProvider).call(movement);
      return ref.read(getAllInventoryMovementsProvider).call();
    });
  }

  Future<void> removeMovement(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteInventoryMovementProvider).call(id);
      return ref.read(getAllInventoryMovementsProvider).call();
    });
  }
}

@riverpod
Future<List<InventoryMovement>> movementsByProduct(
  Ref ref, {
  required int productId,
  int? variantId,
}) {
  return ref
      .watch(getInventoryMovementsByProductProvider)
      .call(productId, variantId: variantId);
}

@riverpod
Future<List<InventoryMovement>> movementsByWarehouse(Ref ref, int warehouseId) {
  return ref.watch(getInventoryMovementsByWarehouseProvider).call(warehouseId);
}

@riverpod
Future<List<InventoryMovement>> movementsByDateRange(
  Ref ref, {
  required DateTime startDate,
  required DateTime endDate,
}) {
  return ref
      .watch(getInventoryMovementsByDateRangeProvider)
      .call(startDate, endDate);
}
