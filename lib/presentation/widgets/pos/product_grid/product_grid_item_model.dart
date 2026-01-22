import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

/// Helper class to represent a product or variant as a single grid item
class ProductGridItem {
  final Product product;
  final ProductVariant? variant;
  final double? realStock;

  ProductGridItem({required this.product, this.variant, this.realStock});

  String get displayName {
    if (variant != null) {
      return '${product.name}\n${variant!.description}';
    }
    return product.name;
  }

  int get priceCents => variant?.priceCents ?? product.salePriceCents;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductGridItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id &&
          variant?.id == other.variant?.id;

  @override
  int get hashCode => product.id.hashCode ^ (variant?.id.hashCode ?? 0);
}
