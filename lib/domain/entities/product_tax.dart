import 'package:flutter/foundation.dart';

@immutable
class ProductTax {
  final int?
  id; // Optional ID if needed for removal, though composite key might differ
  final int? productId;
  final int taxRateId;
  final int applyOrder;

  const ProductTax({
    this.id,
    this.productId,
    required this.taxRateId,
    required this.applyOrder,
  });

  ProductTax copyWith({
    int? id,
    int? productId,
    int? taxRateId,
    int? applyOrder,
  }) {
    return ProductTax(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      taxRateId: taxRateId ?? this.taxRateId,
      applyOrder: applyOrder ?? this.applyOrder,
    );
  }
}
