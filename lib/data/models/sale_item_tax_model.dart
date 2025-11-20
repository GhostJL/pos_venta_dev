import 'package:posventa/domain/entities/sale_item_tax.dart';

class SaleItemTaxModel extends SaleItemTax {
  const SaleItemTaxModel({
    super.id,
    super.saleItemId,
    required super.taxRateId,
    required super.taxName,
    required super.taxRate,
    required super.taxAmountCents,
  });

  factory SaleItemTaxModel.fromJson(Map<String, dynamic> json) {
    return SaleItemTaxModel(
      id: json['id'],
      saleItemId: json['sale_item_id'],
      taxRateId: json['tax_rate_id'],
      taxName: json['tax_name'],
      taxRate: json['tax_rate'],
      taxAmountCents: json['tax_amount_cents'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_item_id': saleItemId,
      'tax_rate_id': taxRateId,
      'tax_name': taxName,
      'tax_rate': taxRate,
      'tax_amount_cents': taxAmountCents,
    };
  }

  factory SaleItemTaxModel.fromEntity(SaleItemTax tax) {
    return SaleItemTaxModel(
      id: tax.id,
      saleItemId: tax.saleItemId,
      taxRateId: tax.taxRateId,
      taxName: tax.taxName,
      taxRate: tax.taxRate,
      taxAmountCents: tax.taxAmountCents,
    );
  }
}
