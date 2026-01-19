import 'package:posventa/domain/entities/purchase_item.dart';

class PurchaseItemModel extends PurchaseItem {
  const PurchaseItemModel({
    super.id,
    super.purchaseId,
    required super.productId,
    super.variantId,
    required super.quantity,
    super.quantityReceived,
    required super.unitOfMeasure,
    required super.unitCostCents,
    required super.subtotalCents,
    super.taxCents,
    required super.totalCents,
    super.lotId,
    super.expirationDate,
    required super.createdAt,
    super.productName,
    super.variantName,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'],
      purchaseId: json['purchase_id'],
      productId: json['product_id'],
      variantId: json['variant_id'],
      quantity: json['quantity'] is int
          ? (json['quantity'] as int).toDouble()
          : json['quantity'],
      quantityReceived: json['quantity_received'] is int
          ? (json['quantity_received'] as int).toDouble()
          : (json['quantity_received'] ?? 0.0),
      unitOfMeasure: json['unit_of_measure'],
      unitCostCents: json['unit_cost_cents'],
      subtotalCents: json['subtotal_cents'],
      taxCents: json['tax_cents'] ?? 0,
      totalCents: json['total_cents'],
      lotId: json['lot_id'],
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      productName: json['product_name'], // Joined field
      variantName: json['variant_name'], // Joined field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
      'quantity_received': quantityReceived,
      'unit_of_measure': unitOfMeasure,
      'unit_cost_cents': unitCostCents,
      'subtotal_cents': subtotalCents,
      'tax_cents': taxCents,
      'total_cents': totalCents,
      'lot_id': lotId,
      'expiration_date': expirationDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PurchaseItemModel.fromEntity(PurchaseItem item) {
    return PurchaseItemModel(
      id: item.id,
      purchaseId: item.purchaseId,
      productId: item.productId,
      variantId: item.variantId,
      quantity: item.quantity,
      quantityReceived: item.quantityReceived,
      unitOfMeasure: item.unitOfMeasure,
      unitCostCents: item.unitCostCents,
      subtotalCents: item.subtotalCents,
      taxCents: item.taxCents,
      totalCents: item.totalCents,
      lotId: item.lotId,
      expirationDate: item.expirationDate,
      createdAt: item.createdAt,
      productName: item.productName,
      variantName: item.variantName,
    );
  }
}
