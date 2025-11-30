import 'package:posventa/domain/entities/product_variant.dart';

class ProductVariantModel extends ProductVariant {
  const ProductVariantModel({
    super.id,
    required super.productId,
    super.barcode,
    super.description,
    required super.quantity,
    required super.priceCents,
    required super.costPriceCents,
    required super.isActive,
  });

  factory ProductVariantModel.fromEntity(ProductVariant variant) {
    return ProductVariantModel(
      id: variant.id,
      productId: variant.productId,
      barcode: variant.barcode,
      description: variant.description,
      quantity: variant.quantity,
      priceCents: variant.priceCents,
      costPriceCents: variant.costPriceCents,
      isActive: variant.isActive,
    );
  }

  factory ProductVariantModel.fromMap(Map<String, dynamic> map) {
    return ProductVariantModel(
      id: map['id'],
      productId: map['product_id'],
      barcode: map['barcode'],
      description: map['description'],
      quantity: (map['quantity'] as num).toDouble(),
      priceCents: map['price_cents'],
      costPriceCents: map['cost_price_cents'],
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'barcode': barcode,
      'description': description,
      'quantity': quantity,
      'price_cents': priceCents,
      'cost_price_cents': costPriceCents,
      'is_active': isActive ? 1 : 0,
    };
  }
}
