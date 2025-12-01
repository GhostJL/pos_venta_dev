import 'package:posventa/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    super.id,
    required super.code,
    required super.name,
    super.description,
    required super.departmentId,
    required super.categoryId,
    super.brandId,
    super.supplierId,
    required super.unitId,
    super.unitName,
    required super.isSoldByWeight,
    required super.isActive,
    super.productTaxes,
    super.variants,
    super.stock,
  });

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      code: product.code,
      name: product.name,
      description: product.description,
      departmentId: product.departmentId,
      categoryId: product.categoryId,
      brandId: product.brandId,
      supplierId: product.supplierId,
      unitId: product.unitId,
      unitName: product.unitName,
      isSoldByWeight: product.isSoldByWeight,
      isActive: product.isActive,
      productTaxes: product.productTaxes,
      variants: product.variants,
      stock: product.stock,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      description: map['description'],
      departmentId: map['department_id'],
      categoryId: map['category_id'],
      brandId: map['brand_id'],
      supplierId: map['supplier_id'],
      unitId: map['unit_id'],
      unitName: map['unit_name'], // Mapped from join
      isSoldByWeight: map['is_sold_by_weight'] == 1,
      isActive: map['is_active'] == 1,
      stock: map['stock'] != null ? (map['stock'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'department_id': departmentId,
      'category_id': categoryId,
      'brand_id': brandId,
      'supplier_id': supplierId,
      'unit_id': unitId,
      // unit_name is not stored in products table, so we don't include it here
      'is_sold_by_weight': isSoldByWeight ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };
  }
}
