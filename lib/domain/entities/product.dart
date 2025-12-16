import 'package:flutter/foundation.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';

@immutable
class Product {
  final int? id;
  final String code;
  final String name;
  final String? description;
  final int? departmentId;
  final String? departmentName; // Populated from join
  final int? categoryId;
  final int? brandId;
  final int? supplierId;
  final int unitId;
  final String? unitName; // Populated from join
  final bool isSoldByWeight;
  final bool isActive;
  final bool hasExpiration;
  final List<ProductTax>? productTaxes;
  final List<ProductVariant>? variants;
  final int? stock;

  const Product({
    this.id,
    required this.code,
    required this.name,
    this.description,
    this.departmentId,
    this.departmentName,
    this.categoryId,
    this.brandId,
    this.supplierId,
    required this.unitId,
    this.unitName,

    this.isSoldByWeight = false,
    this.isActive = true,
    this.hasExpiration = false,
    this.productTaxes,
    this.variants,
    this.stock,
  });

  // Helper getters to maintain compatibility or ease of use
  // Returns the price of the first variant (default) or 0
  double get price {
    if (variants != null && variants!.isNotEmpty) {
      return variants!.first.price;
    }
    return 0.0;
  }

  // Returns the cost price of the first variant or 0
  double get costPrice {
    if (variants != null && variants!.isNotEmpty) {
      return variants!.first.costPrice;
    }
    return 0.0;
  }

  // Returns the barcode of the first variant or null
  String? get barcode {
    if (variants != null && variants!.isNotEmpty) {
      return variants!.first.barcode;
    }
    return null;
  }

  // Compatibility getters
  String get unitOfMeasure => unitName ?? 'pieza';

  int get salePriceCents {
    if (variants != null && variants!.isNotEmpty) {
      return variants!.first.priceCents;
    }
    return 0;
  }

  int get costPriceCents {
    if (variants != null && variants!.isNotEmpty) {
      return variants!.first.costPriceCents;
    }
    return 0;
  }

  int? get wholesalePriceCents {
    if (variants != null && variants!.isNotEmpty) {
      return variants!.first.wholesalePriceCents;
    }
    return null;
  }

  Product copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    int? departmentId,
    String? departmentName,
    int? categoryId,
    int? brandId,
    int? supplierId,
    int? unitId,
    String? unitName,
    bool? isSoldByWeight,
    bool? isActive,
    bool? hasExpiration,
    List<ProductTax>? productTaxes,
    List<ProductVariant>? variants,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      supplierId: supplierId ?? this.supplierId,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      isActive: isActive ?? this.isActive,
      hasExpiration: hasExpiration ?? this.hasExpiration,
      productTaxes: productTaxes ?? this.productTaxes,
      variants: variants ?? this.variants,
      stock: stock ?? this.stock,
    );
  }
}
