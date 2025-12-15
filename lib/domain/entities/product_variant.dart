import 'package:flutter/foundation.dart';

enum VariantType { sales, purchase }

@immutable
class ProductVariant {
  final int? id;
  final int productId;
  final String variantName;
  final String? barcode;
  final double quantity;
  final int priceCents; // sale_price_cents
  final int costPriceCents;
  final int? wholesalePriceCents;
  final bool isActive;
  final bool isForSale;
  final VariantType type;
  final int? linkedVariantId;

  const ProductVariant({
    this.id,
    required this.productId,
    required this.variantName,
    this.barcode,
    this.quantity = 1.0,
    required this.priceCents,
    required this.costPriceCents,
    this.wholesalePriceCents,
    this.isActive = true,
    this.isForSale = true,
    this.type = VariantType.sales,
    this.linkedVariantId,
  });

  double get price => priceCents / 100.0;
  double get costPrice => costPriceCents / 100.0;

  // Compatibility getter
  String get description => variantName;

  ProductVariant copyWith({
    int? id,
    int? productId,
    String? variantName,
    String? barcode,
    double? quantity,
    int? priceCents,
    int? costPriceCents,
    int? wholesalePriceCents,
    bool? isActive,
    bool? isForSale,
    VariantType? type,
    int? linkedVariantId,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantName: variantName ?? this.variantName,
      barcode: barcode ?? this.barcode,
      quantity: quantity ?? this.quantity,
      priceCents: priceCents ?? this.priceCents,
      costPriceCents: costPriceCents ?? this.costPriceCents,
      wholesalePriceCents: wholesalePriceCents ?? this.wholesalePriceCents,
      isActive: isActive ?? this.isActive,
      isForSale: isForSale ?? this.isForSale,
      type: type ?? this.type,
      linkedVariantId: linkedVariantId ?? this.linkedVariantId,
    );
  }
}
