
import 'package:flutter/foundation.dart';

@immutable
class ProductTax {
  final int productId;
  final int taxRateId;
  final int applyOrder;

  const ProductTax({
    required this.productId,
    required this.taxRateId,
    required this.applyOrder,
  });
}
