import 'package:flutter/foundation.dart';

@immutable
class ProductTax {
  final int taxRateId;
  final int applyOrder;

  const ProductTax({required this.taxRateId, required this.applyOrder});

  ProductTax copyWith({int? taxRateId, int? applyOrder}) {
    return ProductTax(
      taxRateId: taxRateId ?? this.taxRateId,
      applyOrder: applyOrder ?? this.applyOrder,
    );
  }
}
