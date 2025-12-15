import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

/// Helper class to represent a product or product variant as a single selectable item
class ProductVariantItem {
  final Product product;
  final ProductVariant? variant;

  ProductVariantItem({required this.product, this.variant});

  String get displayName {
    if (variant != null) {
      final typeStr = variant!.type == VariantType.purchase ? ' (Compra)' : '';
      return '${product.name} - ${variant!.description}$typeStr (Factor: ${variant!.quantity})';
    }
    return product.name;
  }

  int get costPriceCents {
    return variant?.costPriceCents ?? product.costPriceCents;
  }

  String get unitOfMeasure {
    return product.unitOfMeasure;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id &&
          variant?.id == other.variant?.id;

  @override
  int get hashCode => product.id.hashCode ^ (variant?.id.hashCode ?? 0);
}
