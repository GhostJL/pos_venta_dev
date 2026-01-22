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

  /// @deprecated Use Inventory table as single source of truth.
  /// This field is maintained for backwards compatibility but may be out of sync.
  /// Query Inventory table or use product_stock_summary view for accurate stock.
  @Deprecated(
    'Use Inventory table via repository. Will be removed in future version.',
  )
  final int? stock;

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
    this.stock,
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

  // Stock Logic - DEPRECATED
  // Use Inventory table as single source of truth
  // These getters are maintained for backwards compatibility only

  /// @deprecated Use Inventory repository to get accurate stock.
  /// Query: SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = ?
  /// Or use product_stock_summary view for optimized queries.
  @Deprecated('Use Inventory table via repository')
  double get totalStock {
    if (variants == null) return 0;
    return variants!.fold(0.0, (sum, v) => sum + (v.stock ?? 0));
  }

  /// @deprecated Use stockMin from ProductVariant configuration
  @Deprecated('Use variant.stockMin directly')
  double get totalMinStock {
    if (variants == null) return 0;
    return variants!.fold(0.0, (sum, v) => sum + (v.stockMin ?? 0));
  }

  /// @deprecated Use stockMax from ProductVariant configuration
  @Deprecated('Use variant.stockMax directly')
  double get maxStockLimit {
    if (variants == null) return 100;
    double max = 0;
    for (var v in variants!) {
      if ((v.stockMax ?? 0) > max) max = v.stockMax!;
    }
    return max > 0 ? max : 100;
  }

  /// @deprecated Use Inventory repository to check stock levels.
  /// Compare current stock from Inventory with variant.stockMin
  @Deprecated('Use Inventory table via repository')
  bool get isLowStock {
    if (variants == null) return false;
    for (var v in variants!) {
      if ((v.stock ?? 0) <= (v.stockMin ?? 5)) {
        return true;
      }
    }
    return false;
  }

  /// @deprecated Use Inventory repository to check if out of stock.
  /// Query: SELECT quantity_on_hand FROM inventory WHERE product_id = ?
  @Deprecated('Use Inventory table via repository')
  bool get isOutOfStock => totalStock <= 0;

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
    int? stock,
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
      stock: stock ?? this.stock,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id];
}
