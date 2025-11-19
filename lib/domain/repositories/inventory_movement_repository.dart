import 'package:posventa/domain/entities/inventory_movement.dart';

abstract class InventoryMovementRepository {
  Future<List<InventoryMovement>> getAllMovements();
  Future<List<InventoryMovement>> getMovementsByProduct(int productId);
  Future<List<InventoryMovement>> getMovementsByWarehouse(int warehouseId);
  Future<List<InventoryMovement>> getMovementsByType(String movementType);
  Future<List<InventoryMovement>> getMovementsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<InventoryMovement?> getMovementById(int id);
  Future<void> createMovement(InventoryMovement movement);
  Future<void> updateMovement(InventoryMovement movement);
  Future<void> deleteMovement(int id);
}
