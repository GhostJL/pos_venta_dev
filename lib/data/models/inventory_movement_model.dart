import 'package:posventa/domain/entities/inventory_movement.dart';

class InventoryMovementModel extends InventoryMovement {
  InventoryMovementModel({
    super.id,
    required super.productId,
    required super.warehouseId,
    required super.movementType,
    required super.quantity,
    required super.quantityBefore,
    required super.quantityAfter,
    super.referenceType,
    super.referenceId,
    super.lotId,
    super.reason,
    required super.performedBy,
    super.movementDate,
  });

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    return InventoryMovementModel(
      id: json['id'],
      productId: json['product_id'],
      warehouseId: json['warehouse_id'],
      movementType: MovementType.fromString(json['movement_type']),
      quantity: (json['quantity'] as num).toDouble(),
      quantityBefore: (json['quantity_before'] as num).toDouble(),
      quantityAfter: (json['quantity_after'] as num).toDouble(),
      referenceType: json['reference_type'],
      referenceId: json['reference_id'],
      lotId: json['lot_id'],
      reason: json['reason'],
      performedBy: json['performed_by'],
      movementDate: DateTime.parse(json['movement_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'warehouse_id': warehouseId,
      'movement_type': movementType.value,
      'quantity': quantity,
      'quantity_before': quantityBefore,
      'quantity_after': quantityAfter,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'lot_id': lotId,
      'reason': reason,
      'performed_by': performedBy,
      'movement_date': movementDate.toIso8601String(),
    };
  }

  factory InventoryMovementModel.fromEntity(InventoryMovement movement) {
    return InventoryMovementModel(
      id: movement.id,
      productId: movement.productId,
      warehouseId: movement.warehouseId,
      movementType: movement.movementType,
      quantity: movement.quantity,
      quantityBefore: movement.quantityBefore,
      quantityAfter: movement.quantityAfter,
      referenceType: movement.referenceType,
      referenceId: movement.referenceId,
      lotId: movement.lotId,
      reason: movement.reason,
      performedBy: movement.performedBy,
      movementDate: movement.movementDate,
    );
  }
}
