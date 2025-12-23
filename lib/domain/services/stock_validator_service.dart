import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/sale_item.dart';

class StockValidatorService {
  Future<String?> validateStock({
    required Product product,
    required double quantityToAdd,
    ProductVariant? variant,
    required List<SaleItem> currentCart,
  }) async {
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

      final totalNeeded = currentStockInCart + quantityToAdd;

      // Check if enough stock
      if (availableStock < totalNeeded) {
        return 'Stock insuficiente$stockLabel (disponible: ${availableStock.toStringAsFixed(0)})';
      }

      return null; // Stock OK
    } catch (e) {
      return 'Error al validar stock: $e';
    }
  }
}
