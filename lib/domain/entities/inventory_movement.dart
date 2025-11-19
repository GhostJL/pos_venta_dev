enum MovementType {
  purchase('purchase', 'Compra'),
  sale('sale', 'Venta'),
  adjustment('adjustment', 'Ajuste'),
  transferOut('transfer_out', 'Traspaso Salida'),
  transferIn('transfer_in', 'Traspaso Entrada'),
  returnMovement('return', 'Devolución'),
  damage('damage', 'Merma/Daño');

  final String value;
  final String displayName;

  const MovementType(this.value, this.displayName);

  static MovementType fromString(String value) {
    return MovementType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MovementType.adjustment,
    );
  }
}

class InventoryMovement {
  final int? id;
  final int productId;
  final int warehouseId;
  final MovementType movementType;
  final double quantity;
  final double quantityBefore;
  final double quantityAfter;
  final String? referenceType;
  final int? referenceId;
  final String? lotNumber;
  final String? reason;
  final int performedBy;
  final DateTime movementDate;

  InventoryMovement({
    this.id,
    required this.productId,
    required this.warehouseId,
    required this.movementType,
    required this.quantity,
    required this.quantityBefore,
    required this.quantityAfter,
    this.referenceType,
    this.referenceId,
    this.lotNumber,
    this.reason,
    required this.performedBy,
    DateTime? movementDate,
  }) : movementDate = movementDate ?? DateTime.now();

  InventoryMovement copyWith({
    int? id,
    int? productId,
    int? warehouseId,
    MovementType? movementType,
    double? quantity,
    double? quantityBefore,
    double? quantityAfter,
    String? referenceType,
    int? referenceId,
    String? lotNumber,
    String? reason,
    int? performedBy,
    DateTime? movementDate,
  }) {
    return InventoryMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      quantityBefore: quantityBefore ?? this.quantityBefore,
      quantityAfter: quantityAfter ?? this.quantityAfter,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      lotNumber: lotNumber ?? this.lotNumber,
      reason: reason ?? this.reason,
      performedBy: performedBy ?? this.performedBy,
      movementDate: movementDate ?? this.movementDate,
    );
  }

  bool get isIncoming => quantity > 0;
  bool get isOutgoing => quantity < 0;
}
