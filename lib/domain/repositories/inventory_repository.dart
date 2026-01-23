import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';

abstract class InventoryRepository {
  Future<List<Inventory>> getAllInventory();
  Stream<List<Inventory>> getAllInventoryStream();
  Future<List<Inventory>> getInventoryByProduct(int productId);
  Future<List<Inventory>> getInventoryByWarehouse(int warehouseId);
  Future<Inventory?> getInventoryById(int id);
  Future<void> createInventory(Inventory inventory);
  Future<void> updateInventory(Inventory inventory);
  Future<void> deleteInventory(int id);
  Future<void> deleteInventoryForProductVariant(
    int productId,
    int warehouseId,
    int variantId,
  );
  Future<void> adjustInventory(InventoryMovement movement);
  Future<void> adjustInventoryBatch(List<InventoryMovement> movements);
  Future<void> transferInventory({
    required int fromWarehouseId,
    required int toWarehouseId,
    required int productId,
    required double quantity,
    required int userId,
    String? reason,
  });
  Future<void> recalculateInventory(int productId);

  /// Recalculates inventory quantities based on lots
  Future<void> reconcileInventory();

  /// Deletes all inventory data (Destructive)
  Future<void> resetAllInventory();
}
