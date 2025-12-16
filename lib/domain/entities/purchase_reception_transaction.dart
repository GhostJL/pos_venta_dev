import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';

class PurchaseReceptionTransaction {
  final int purchaseId;
  final String newStatus;
  final int receivedBy;
  final DateTime receivedDate;

  /// List of items to update (e.g. quantity_received, lot_id)
  final List<PurchaseItemUpdate> itemUpdates;

  /// New lots to create
  final List<InventoryLot> newLots;

  /// Inventory adjustments (stock increments)
  final List<InventoryAdjustment> inventoryAdjustments;

  /// Movements to record
  final List<InventoryMovement> movements;

  /// Variant cost updates
  final List<ProductVariantUpdate> variantUpdates;

  PurchaseReceptionTransaction({
    required this.purchaseId,
    required this.newStatus,
    required this.receivedBy,
    required this.receivedDate,
    required this.itemUpdates,
    required this.newLots,
    required this.inventoryAdjustments,
    required this.movements,
    required this.variantUpdates,
  });
}

class PurchaseItemUpdate {
  final int itemId;
  final double quantityReceived;
  final int? lotId; // This might be tricky if lot ID is generated DB-side.
  // We might need to rely on the order of insertion or use a temporary ID if supported.
  // For now, let's assume we insert lots first and get IDs, OR we do it all in one go.
  // Actually, if we want to be atomic, we can't "get IDs" in the middle easily without a callback.
  // A common trick is to insert lots, get IDs, then update items.
  // But if we want ONE transaction, we need to do it in the repo.
  // Let's assume the Repo handles the linking if we pass the Lot object with the Item update.

  // To simplify, let's say we pass the Lot object itself if it's new, or ID if existing.
  final InventoryLot? newLot;

  PurchaseItemUpdate({
    required this.itemId,
    required this.quantityReceived,
    this.lotId,
    this.newLot,
  });
}

class InventoryAdjustment {
  final int productId;
  final int warehouseId;
  final int? variantId;
  final double quantityToAdd;

  InventoryAdjustment({
    required this.productId,
    this.variantId,
    required this.warehouseId,
    required this.quantityToAdd,
  });
}

class ProductVariantUpdate {
  final int variantId;
  final int newCostPriceCents;

  ProductVariantUpdate({
    required this.variantId,
    required this.newCostPriceCents,
  });
}
