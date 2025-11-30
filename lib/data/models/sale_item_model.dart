import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_item_tax.dart';

class SaleItemModel extends SaleItem {
  const SaleItemModel({
    super.id,
    super.saleId,
    required super.productId,
    super.variantId,
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
    super.taxes,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'],
      saleId: json['sale_id'],
      productId: json['product_id'],
      variantId: json['variant_id'],
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
      'variant_id': variantId,
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
      variantId: item.variantId,
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
      taxes: item.taxes,
    );
  }

  SaleItemModel copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? variantId,
    double? quantity,
    String? unitOfMeasure,
    int? unitPriceCents,
    int? discountCents,
    int? subtotalCents,
    int? taxCents,
    int? totalCents,
    int? costPriceCents,
    String? lotNumber,
    String? productName,
    List<SaleItemTax>? taxes,
  }) {
    return SaleItemModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      discountCents: discountCents ?? this.discountCents,
      subtotalCents: subtotalCents ?? this.subtotalCents,
      taxCents: taxCents ?? this.taxCents,
      totalCents: totalCents ?? this.totalCents,
      costPriceCents: costPriceCents ?? this.costPriceCents,
      lotNumber: lotNumber ?? this.lotNumber,
      productName: productName ?? this.productName,
      taxes: taxes ?? this.taxes,
    );
  }
}
