import 'package:posventa/domain/entities/purchase_item.dart';

class PurchaseItemModel extends PurchaseItem {
  const PurchaseItemModel({
    super.id,
    super.purchaseId,
    required super.productId,
    required super.quantity,
    required super.unitOfMeasure,
    required super.unitCostCents,
    required super.subtotalCents,
    super.taxCents,
    required super.totalCents,
    super.lotNumber,
    super.expirationDate,
    required super.createdAt,
    super.productName,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'],
      purchaseId: json['purchase_id'],
      productId: json['product_id'],
      quantity: json['quantity'] is int
          ? (json['quantity'] as int).toDouble()
          : json['quantity'],
      unitOfMeasure: json['unit_of_measure'],
      unitCostCents: json['unit_cost_cents'],
      subtotalCents: json['subtotal_cents'],
      taxCents: json['tax_cents'] ?? 0,
      totalCents: json['total_cents'],
      lotNumber: json['lot_number'],
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      productName: json['product_name'], // Joined field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'quantity': quantity,
      'unit_of_measure': unitOfMeasure,
      'unit_cost_cents': unitCostCents,
      'subtotal_cents': subtotalCents,
      'tax_cents': taxCents,
      'total_cents': totalCents,
      'lot_number': lotNumber,
      'expiration_date': expirationDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PurchaseItemModel.fromEntity(PurchaseItem item) {
    return PurchaseItemModel(
      id: item.id,
      purchaseId: item.purchaseId,
      productId: item.productId,
      quantity: item.quantity,
      unitOfMeasure: item.unitOfMeasure,
      unitCostCents: item.unitCostCents,
      subtotalCents: item.subtotalCents,
      taxCents: item.taxCents,
      totalCents: item.totalCents,
      lotNumber: item.lotNumber,
      expirationDate: item.expirationDate,
      createdAt: item.createdAt,
      productName: item.productName,
    );
  }
}
