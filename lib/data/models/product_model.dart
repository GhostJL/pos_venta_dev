import 'package:posventa/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    super.id,
    required super.code,
    super.barcode,
    required super.name,
    super.description,
    required super.departmentId,
    required super.categoryId,
    super.brandId,
    super.supplierId,
    required super.unitOfMeasure,
    required super.isSoldByWeight,
    required super.costPriceCents,
    required super.salePriceCents,
    super.wholesalePriceCents,
    required super.isActive,
    super.productTaxes,
    super.stock,
  });

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      code: product.code,
      barcode: product.barcode,
      name: product.name,
      description: product.description,
      departmentId: product.departmentId,
      categoryId: product.categoryId,
      brandId: product.brandId,
      supplierId: product.supplierId,
      unitOfMeasure: product.unitOfMeasure,
      isSoldByWeight: product.isSoldByWeight,
      costPriceCents: product.costPriceCents,
      salePriceCents: product.salePriceCents,
      wholesalePriceCents: product.wholesalePriceCents,
      isActive: product.isActive,
      productTaxes: product.productTaxes,
      stock: product.stock,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      code: map['code'],
      barcode: map['barcode'],
      name: map['name'],
      description: map['description'],
      departmentId: map['department_id'],
      categoryId: map['category_id'],
      brandId: map['brand_id'],
      supplierId: map['supplier_id'],
      unitOfMeasure: map['unit_of_measure'],
      isSoldByWeight: map['is_sold_by_weight'] == 1,
      costPriceCents: map['cost_price_cents'],
      salePriceCents: map['sale_price_cents'],
      wholesalePriceCents: map['wholesale_price_cents'],
      isActive: map['is_active'] == 1,
      stock: map['stock'] != null ? (map['stock'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'barcode': barcode != null && barcode!.isNotEmpty ? barcode : null,
      'name': name,
      'description': description,
      'department_id': departmentId,
      'category_id': categoryId,
      'brand_id': brandId,
      'supplier_id': supplierId,
      'unit_of_measure': unitOfMeasure,
      'is_sold_by_weight': isSoldByWeight ? 1 : 0,
      'cost_price_cents': costPriceCents,
      'sale_price_cents': salePriceCents,
      'wholesale_price_cents': wholesalePriceCents,
      'is_active': isActive ? 1 : 0,
    };
  }
}
