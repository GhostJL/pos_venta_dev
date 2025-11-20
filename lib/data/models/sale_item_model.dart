import 'package:posventa/domain/entities/sale_item.dart';

class SaleItemModel extends SaleItem {
  const SaleItemModel({
    super.id,
    super.saleId,
    required super.productId,
    required super.quantity,
    required super.unitOfMeasure,
    required super.unitPriceCents,
    super.discountCents,
    required super.subtotalCents,
    super.taxCents,
    required super.totalCents,
    required super.costPriceCents,
    super.lotNumber,
    super.productName,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'],
      saleId: json['sale_id'],
      productId: json['product_id'],
      quantity: (json['quantity'] as num).toDouble(),
      unitOfMeasure: json['unit_of_measure'],
      unitPriceCents: json['unit_price_cents'],
      discountCents: json['discount_cents'] ?? 0,
      subtotalCents: json['subtotal_cents'],
      taxCents: json['tax_cents'] ?? 0,
      totalCents: json['total_cents'],
      costPriceCents: json['cost_price_cents'],
      lotNumber: json['lot_number'],
      productName: json['product_name'], // Joined field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_of_measure': unitOfMeasure,
      'unit_price_cents': unitPriceCents,
      'discount_cents': discountCents,
      'subtotal_cents': subtotalCents,
      'tax_cents': taxCents,
      'total_cents': totalCents,
      'cost_price_cents': costPriceCents,
      'lot_number': lotNumber,
    };
  }

  factory SaleItemModel.fromEntity(SaleItem item) {
    return SaleItemModel(
      id: item.id,
      saleId: item.saleId,
      productId: item.productId,
      quantity: item.quantity,
      unitOfMeasure: item.unitOfMeasure,
      unitPriceCents: item.unitPriceCents,
      discountCents: item.discountCents,
      subtotalCents: item.subtotalCents,
      taxCents: item.taxCents,
      totalCents: item.totalCents,
      costPriceCents: item.costPriceCents,
      lotNumber: item.lotNumber,
      productName: item.productName,
    );
  }
}
