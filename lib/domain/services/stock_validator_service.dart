import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/sale_item.dart';

class StockValidatorService {
  double _round(double value) {
    // Use a high precision for internal stock validation to avoid 0.1 + 0.2 != 0.3 issues
    // while allowing for standard weight handling (e.g. 3 decimals).
    // Using 6 decimals is generally safe for avoiding floating point drift.
    return double.parse(value.toStringAsFixed(6));
  }

  Future<String?> validateStock({
    required Product product,
    required double quantityToAdd,
    ProductVariant? variant,
    required List<SaleItem> currentCart,
    bool useInventory = true,
  }) async {
    if (!useInventory) return null; // Bypass check

    try {
      double availableStock = 0.0;
      String stockLabel = '';

      if (variant != null) {
        // Use variant specific stock
        availableStock = variant.stock ?? 0.0;
        stockLabel = 'de la variante';
      } else {
        // Base product stock
        availableStock = product.stock == null
            ? 0.0
            : product.stock!.toDouble();
      }

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
        return 'Stock insuficiente$stockLabel (disponible: ${availableRounded.toStringAsFixed(2)})';
      }

      return null; // Stock OK
    } catch (e) {
      return 'Error al validar stock: $e';
    }
  }
}
