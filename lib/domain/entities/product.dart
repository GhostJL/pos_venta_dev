
import 'package:flutter/foundation.dart';

@immutable
class Product {
  final int? id;
  final String code;
  final String? barcode;
  final String name;
  final String? description;
  final int departmentId;
  final int categoryId;
  final int? brandId;
  final int? supplierId;
  final String unitOfMeasure;
  final bool isSoldByWeight;
  final int costPriceCents;
  final int salePriceCents;
  final int? wholesalePriceCents;
  final bool isActive;

  const Product({
    this.id,
    required this.code,
    this.barcode,
    required this.name,
    this.description,
    required this.departmentId,
    required this.categoryId,
    this.brandId,
    this.supplierId,
    required this.unitOfMeasure,
    this.isSoldByWeight = false,
    required this.costPriceCents,
    required this.salePriceCents,
    this.wholesalePriceCents,
    this.isActive = true,
  });
}
