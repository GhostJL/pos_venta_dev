import 'package:posventa/domain/entities/product_variant.dart';

class ProductVariantModel extends ProductVariant {
  const ProductVariantModel({
    super.id,
    required super.productId,
    required super.variantName,
    super.barcode,
    required super.quantity,
    required super.priceCents,
    required super.costPriceCents,
    super.wholesalePriceCents,
    required super.isActive,
    required super.isForSale,
    required super.type,
    super.linkedVariantId,
    super.stock,
    super.stockMin,
    super.stockMax,
    super.conversionFactor,
    super.unitId,
    super.isSoldByWeight,
    super.photoUrl,
  });

  factory ProductVariantModel.fromEntity(ProductVariant variant) {
    return ProductVariantModel(
      id: variant.id,
      productId: variant.productId,
      variantName: variant.variantName,
      barcode: variant.barcode,
      quantity: variant.quantity,
      priceCents: variant.priceCents,
      costPriceCents: variant.costPriceCents,
      wholesalePriceCents: variant.wholesalePriceCents,
      isActive: variant.isActive,
      isForSale: variant.isForSale,
      type: variant.type,
      linkedVariantId: variant.linkedVariantId,
      stock: variant.stock,
      stockMin: variant.stockMin,
      stockMax: variant.stockMax,
      conversionFactor: variant.conversionFactor,
      unitId: variant.unitId,
      isSoldByWeight: variant.isSoldByWeight,
      photoUrl: variant.photoUrl,
    );
  }

  factory ProductVariantModel.fromMap(Map<String, dynamic> map) {
    return ProductVariantModel(
      id: map['id'],
      productId: map['product_id'],
      variantName:
          map['variant_name'] ?? '', // Handle potential nulls during dev
      barcode: map['barcode'],
      quantity: (map['quantity'] as num).toDouble(),
      priceCents: map['sale_price_cents'], // Mapped from sale_price_cents in DB
      costPriceCents: map['cost_price_cents'],
      wholesalePriceCents: map['wholesale_price_cents'],
      isActive: map['is_active'] == 1,
      isForSale: map['is_for_sale'] == null ? true : map['is_for_sale'] == 1,
      type: map['type'] == 'purchase'
          ? VariantType.purchase
          : VariantType.sales,
      linkedVariantId: map['linked_variant_id'],
      stock: map['stock'] != null ? (map['stock'] as num).toDouble() : null,
      stockMin: map['stock_min'] != null
          ? (map['stock_min'] as num).toDouble()
          : null,
      stockMax: map['stock_max'] != null
          ? (map['stock_max'] as num).toDouble()
          : null,
      conversionFactor: map['conversion_factor'] != null
          ? (map['conversion_factor'] as num).toDouble()
          : 1.0,
      unitId: map['unit_id'],
      isSoldByWeight: map['is_sold_by_weight'] == 1,
      photoUrl: map['photo_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'variant_name': variantName,
      'barcode': barcode,
      'quantity': quantity,
      'sale_price_cents': priceCents, // Mapped to sale_price_cents in DB
      'cost_price_cents': costPriceCents,
      'wholesale_price_cents': wholesalePriceCents,
      'is_active': isActive ? 1 : 0,
      'is_for_sale': isForSale ? 1 : 0,
      'type': type == VariantType.purchase ? 'purchase' : 'sales',
      'linked_variant_id': linkedVariantId,
      'stock_min': stockMin,
      'stock_max': stockMax,
      'conversion_factor': conversionFactor,
      'unit_id': unitId,
      'is_sold_by_weight': isSoldByWeight ? 1 : 0,
      'photo_url': photoUrl,
    };
  }
}
