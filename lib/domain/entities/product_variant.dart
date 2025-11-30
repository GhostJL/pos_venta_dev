import 'package:flutter/foundation.dart';

@immutable
class ProductVariant {
  final int? id;
  final int productId;
  final String? barcode;
  final String? description;
  final double quantity;
  final int priceCents;
  final int costPriceCents;
  final bool isActive;

  const ProductVariant({
    this.id,
    required this.productId,
    this.barcode,
    this.description,
    this.quantity = 1.0,
    required this.priceCents,
    required this.costPriceCents,
    this.isActive = true,
  });

  double get price => priceCents / 100.0;
  double get costPrice => costPriceCents / 100.0;

  ProductVariant copyWith({
    int? id,
    int? productId,
    String? barcode,
    String? description,
    double? quantity,
    int? priceCents,
    int? costPriceCents,
    bool? isActive,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      priceCents: priceCents ?? this.priceCents,
      costPriceCents: costPriceCents ?? this.costPriceCents,
      isActive: isActive ?? this.isActive,
    );
  }
}
