import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/core/error/domain_exceptions.dart';
import 'package:posventa/core/error/error_reporter.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class StockValidatorService {
  final InventoryRepository _inventoryRepository;

  StockValidatorService(this._inventoryRepository);

  double _round(double value) {
    return double.parse(value.toStringAsFixed(6));
  }

  Future<void> validateStock({
    required Product product,
    required double quantityToAdd,
    ProductVariant? variant,
    required List<SaleItem> currentCart,
    bool useInventory = true,
  }) async {
    if (!useInventory) return; // Bypass check

    try {
      double availableStock = 0.0;

      // Use a consistent warehouse ID (default 1 for now, as used in other fallback logic)
      // Ideally this should come from the current session context passed to this method
      const int warehouseId = 1;

      // Check real stock from Inventory table (Single Source of Truth)
      final inventoryList = await _inventoryRepository.getInventoryByProduct(
        product.id!,
      );

      final inventory = inventoryList.firstWhere(
        (i) => i.warehouseId == warehouseId && i.variantId == variant?.id,
        orElse: () => Inventory(
          productId: product.id!,
          warehouseId: warehouseId,
          variantId: variant?.id,
          quantityOnHand: 0.0,
        ),
      );

      availableStock = inventory.quantityOnHand;

      // Verify against cached stock as a secondary check or for display consistency?
      // No, let's trust lots as they are the source of truth for sales.
      // If we used cached product.stock, we run into the bug where UI says 12 but lots are 0.

      // Calculate total quantity needed (existing in cart + new)
      final currentStockInCart = currentCart
          .where(
            (item) =>
                item.productId == product.id && item.variantId == variant?.id,
          )
          .fold(0.0, (sum, item) => sum + item.quantity);

      final totalNeeded = _round(currentStockInCart + quantityToAdd);
      final availableRounded = _round(availableStock);

      // Check if enough stock
      if (availableRounded < totalNeeded) {
        throw StockInsufficientException(
          productName: variant != null
              ? '${product.name} (${variant.variantName})'
              : product.name,
          currentStock: availableRounded,
          requestedQuantity: totalNeeded,
        );
      }
    } catch (e) {
      if (e is StockInsufficientException) {
        rethrow; // Allow domain specific exceptions to bubble up
      }
      AppErrorReporter().reportError(
        e,
        StackTrace.current,
        context: 'StockValidation',
      );
      throw Exception('Error al validar stock real: $e');
    }
  }
}
