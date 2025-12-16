import 'package:posventa/domain/entities/inventory_lot.dart';

abstract class InventoryLotRepository {
  /// Get all lots for a specific product and warehouse
  Future<List<InventoryLot>> getLotsByProduct(int productId, int warehouseId);

  /// Get only available lots (quantity > 0) for a product and warehouse
  /// Ordered by received_at ASC (FIFO)
  Future<List<InventoryLot>> getAvailableLots(
    int productId,
    int warehouseId, {
    int? variantId,
  });

  /// Get a specific lot by ID
  Future<InventoryLot?> getLotById(int id);

  /// Create a new lot
  Future<int> createLot(InventoryLot lot);

  /// Update the quantity of a lot
  Future<void> updateLotQuantity(int lotId, double newQuantity);

  /// Generate a unique lot number
  /// Format: LOT-YYYYMMDD-XXXX
  String generateLotNumber();

  /// Get lots that are expiring soon (within days)
  Future<List<InventoryLot>> getExpiringLots(int warehouseId, int withinDays);

  /// Get all lots for a warehouse
  Future<List<InventoryLot>> getLotsByWarehouse(int warehouseId);
}
