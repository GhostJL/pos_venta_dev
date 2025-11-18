import 'package:posventa/domain/entities/product_tax.dart';

class ProductTaxModel extends ProductTax {
  const ProductTaxModel({
    required super.taxRateId,
    required super.applyOrder,
  });

  factory ProductTaxModel.fromEntity(ProductTax productTax) {
    return ProductTaxModel(
      taxRateId: productTax.taxRateId,
      applyOrder: productTax.applyOrder,
    );
  }

  factory ProductTaxModel.fromMap(Map<String, dynamic> map) {
    return ProductTaxModel(
      taxRateId: map['tax_rate_id'],
      applyOrder: map['apply_order'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tax_rate_id': taxRateId,
      'apply_order': applyOrder,
    };
  }
}
