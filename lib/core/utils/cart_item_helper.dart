import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

class CartItemHelper {
  final PurchaseItem item;
  final Product? product;

  CartItemHelper({required this.item, required this.product});

  ProductVariant? get variant {
    if (item.variantId == null || product == null) return null;
    return product!.variants?.where((v) => v.id == item.variantId).firstOrNull;
  }

  double get step => variant?.quantity ?? 1.0;

  ({double qty, String unit, double cost, double refCost, bool hasVariant})
  get priceData {
    if (product == null) {
      return (
        qty: item.quantity,
        unit: item.unitOfMeasure,
        cost: item.unitCost,
        refCost: 0.0,
        hasVariant: false,
      );
    }

    final v = variant;
    if (v != null) {
      final qty = item.quantity / v.quantity;
      return (
        qty: qty,
        unit: 'cajas/paq',
        cost: (item.subtotalCents / 100.0) / qty,
        refCost: v.costPriceCents / 100.0,
        hasVariant: true,
      );
    }
    return (
      qty: item.quantity,
      unit: item.unitOfMeasure,
      cost: item.unitCost,
      refCost: product!.costPriceCents / 100.0,
      hasVariant: false,
    );
  }
}
