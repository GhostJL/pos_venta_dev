import 'package:flutter/foundation.dart';
import 'package:posventa/domain/entities/product_tax.dart';

@immutable
class Product {
  final int? id;
  final String code;
  final String? barcode;
  final String name;
  final String? description;
  final int? departmentId;
  final int? categoryId;
  final int? brandId;
  final int? supplierId;
  final String unitOfMeasure;
  final bool isSoldByWeight;
  final int costPriceCents;
  final int salePriceCents;
  final int? wholesalePriceCents;
  final bool isActive;
  final List<ProductTax>? productTaxes;
  final double? stock;

  const Product({
    this.id,
    required this.code,
    this.barcode,
    required this.name,
    this.description,
    this.departmentId,
    this.categoryId,
    this.brandId,
    this.supplierId,
    required this.unitOfMeasure,
    this.isSoldByWeight = false,
    required this.costPriceCents,
    required this.salePriceCents,
    this.wholesalePriceCents,
    this.isActive = true,
    this.productTaxes,
    this.stock,
  });

  double get price => salePriceCents / 100.0;
  double get costPrice => costPriceCents / 100.0;

  Product copyWith({
    int? id,
    String? code,
    String? barcode,
    String? name,
    String? description,
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
    String? unitOfMeasure,
    bool? isSoldByWeight,
    int? costPriceCents,
    int? salePriceCents,
    int? wholesalePriceCents,
    bool? isActive,
    List<ProductTax>? productTaxes,
    double? stock,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      description: description ?? this.description,
      departmentId: departmentId ?? this.departmentId,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      supplierId: supplierId ?? this.supplierId,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      costPriceCents: costPriceCents ?? this.costPriceCents,
      salePriceCents: salePriceCents ?? this.salePriceCents,
      wholesalePriceCents: wholesalePriceCents ?? this.wholesalePriceCents,
      isActive: isActive ?? this.isActive,
      productTaxes: productTaxes ?? this.productTaxes,
      stock: stock ?? this.stock,
    );
  }
}
