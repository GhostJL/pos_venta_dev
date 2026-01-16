import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/core/error/domain_exceptions.dart';
import 'package:posventa/core/error/error_reporter.dart';

class StockValidatorService {
  double _round(double value) {
    // Use a high precision for internal stock validation to avoid 0.1 + 0.2 != 0.3 issues
    // while allowing for standard weight handling (e.g. 3 decimals).
    // Using 6 decimals is generally safe for avoiding floating point drift.
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

      if (variant != null) {
        availableStock = variant.stock ?? 0.0;
      } else {
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
        throw StockInsufficientException(
          productName: variant != null
              ? '${product.name} (${variant.variantName})'
              : product.name,
          currentStock: availableRounded,
          requestedQuantity: totalNeeded,
        );
      }
    } catch (e) {
      if (e is StockInsufficientException)
        rethrow; // Allow domain specific exceptions to bubble up
      // Log unexpected errors but maybe don't block the sale if validation fails due to code error?
      // Or safer to block? Let's throw an App Exception.
      AppErrorReporter().reportError(
        e,
        StackTrace.current,
        context: 'StockValidation',
      );
      throw Exception('Error al validar stock: $e');
    }
  }
}
