import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';

/// Transaction data for creating a sale
/// Contains all prepared data for atomic DB execution
class SaleTransaction {
  final Sale sale;

  /// Lot deductions: for each sale item, which lots to deduct from and how much
  final List<SaleItemLotDeduction> lotDeductions;

  /// Inventory adjustments (stock decrements)
  final List<InventoryAdjustment> inventoryAdjustments;

  /// Movements to record
  final List<InventoryMovement> movements;

  SaleTransaction({
    required this.sale,
    required this.lotDeductions,
    required this.inventoryAdjustments,
    required this.movements,
  });
}

/// Represents which lots to deduct for a specific sale item
class SaleItemLotDeduction {
  final SaleItem saleItem;
  final List<LotDeduction> deductions;

  SaleItemLotDeduction({required this.saleItem, required this.deductions});
}

/// Specific lot deduction amount
class LotDeduction {
  final int lotId;
  final double quantityToDeduct;

  LotDeduction({required this.lotId, required this.quantityToDeduct});
}

class InventoryAdjustment {
  final int productId;
  final int? variantId;
  final int warehouseId;
  final double quantityToDeduct; // Negative for sales

  InventoryAdjustment({
    required this.productId,
    this.variantId,
    required this.warehouseId,
    required this.quantityToDeduct,
  });
}

/// Transaction data for canceling a sale
class SaleCancellationTransaction {
  final int saleId;
  final int userId;
  final String reason;
  final DateTime cancelledAt;

  /// Lot restorations: which lots to restore and how much
  final List<LotRestoration> lotRestorations;

  /// Inventory adjustments (stock increments)
  final List<InventoryAdjustment> inventoryAdjustments;

  /// Movements to record
  final List<InventoryMovement> movements;

  SaleCancellationTransaction({
    required this.saleId,
    required this.userId,
    required this.reason,
    required this.cancelledAt,
    required this.lotRestorations,
    required this.inventoryAdjustments,
    required this.movements,
  });
}

class LotRestoration {
  final int lotId;
  final double quantityToRestore;

  LotRestoration({required this.lotId, required this.quantityToRestore});
}
