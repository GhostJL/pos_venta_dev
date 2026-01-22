import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';

@immutable
class Product extends Equatable {
  final int? id;
  final String code;
  final String name;
  final String? description;
  final int? departmentId;
  final String? departmentName; // Populated from join
  final int? categoryId;
  final int? brandId;
  final int? supplierId;
  final bool isSoldByWeight;
  final bool isActive;
  final bool hasExpiration;
  final List<ProductTax>? productTaxes;
  final List<ProductVariant>? variants;
  final String? photoUrl;

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

    this.isSoldByWeight = false,
    this.isActive = true,
    this.hasExpiration = false,
    this.productTaxes,
    this.variants,
    this.photoUrl,
  });

  // Helper getters to maintain compatibility or ease of use
  bool get isVariableProduct => variants != null && variants!.isNotEmpty;

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
  String get unitOfMeasure {
    if (variants != null && variants!.isNotEmpty) {
      // Logic to get unit name from variant if we had it there?
      // Variant currently maps unitId but doesn't have the NAME attached directly usually unless joined.
      // For now, let's return a default or 'pieza' as placeholder if we can't resolve it easily
      // without extra joins. Ideally, we should fetch unit name in variant query.
      return 'pieza';
    }
    return 'pieza';
  }

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

  // Stock removed - use Inventory table via repository
  // Query Inventory directly or use product_stock_summary view

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
    bool? isSoldByWeight,
    bool? isActive,
    bool? hasExpiration,
    List<ProductTax>? productTaxes,
    List<ProductVariant>? variants,
    String? photoUrl,
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
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      isActive: isActive ?? this.isActive,
      hasExpiration: hasExpiration ?? this.hasExpiration,
      productTaxes: productTaxes ?? this.productTaxes,
      variants: variants ?? this.variants,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id];
}
