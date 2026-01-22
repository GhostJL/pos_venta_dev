import '../../domain/entities/inventory_lot.dart';

class InventoryLotModel extends InventoryLot {
  const InventoryLotModel({
    required super.id,
    required super.productId,
    super.variantId,
    required super.warehouseId,
    required super.lotNumber,
    required super.quantity,
    required super.originalQuantity,
    required super.unitCostCents,
    required super.totalCostCents,
    super.expirationDate,
    required super.receivedAt,
  });

  factory InventoryLotModel.fromJson(Map<String, dynamic> json) {
    return InventoryLotModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      variantId: json['variant_id'] as int?,
      warehouseId: json['warehouse_id'] as int,
      lotNumber: json['lot_number'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      originalQuantity:
          (json['original_quantity'] as num?)?.toDouble() ??
          (json['quantity'] as num).toDouble(),
      unitCostCents: json['unit_cost_cents'] as int,
      totalCostCents: json['total_cost_cents'] as int,
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      receivedAt: DateTime.parse(json['received_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'variant_id': variantId,
      'warehouse_id': warehouseId,
      'lot_number': lotNumber,
      'quantity': quantity,
      'original_quantity': originalQuantity,
      'unit_cost_cents': unitCostCents,
      'total_cost_cents': totalCostCents,
      'expiration_date': expirationDate?.toIso8601String(),
      'received_at': receivedAt.toIso8601String(),
    };
  }

  factory InventoryLotModel.fromEntity(InventoryLot entity) {
    return InventoryLotModel(
      id: entity.id,
      productId: entity.productId,
      variantId: entity.variantId,
      warehouseId: entity.warehouseId,
      lotNumber: entity.lotNumber,
      quantity: entity.quantity,
      originalQuantity: entity.originalQuantity,
      unitCostCents: entity.unitCostCents,
      totalCostCents: entity.totalCostCents,
      expirationDate: entity.expirationDate,
      receivedAt: entity.receivedAt,
    );
  }
}
