import 'package:posventa/domain/entities/cash_movement.dart';

class CashMovementModel extends CashMovement {
  CashMovementModel({
    super.id,
    required super.cashSessionId,
    required super.movementType,
    required super.amountCents,
    required super.reason,
    super.description,
    required super.performedBy,
    required super.movementDate,
  });

  factory CashMovementModel.fromMap(Map<String, dynamic> map) {
    return CashMovementModel(
      id: map['id'],
      cashSessionId: map['cash_session_id'],
      movementType: map['movement_type'],
      amountCents: map['amount_cents'],
      reason: map['reason'],
      description: map['description'],
      performedBy: map['performed_by'],
      movementDate: DateTime.parse(map['movement_date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cash_session_id': cashSessionId,
      'movement_type': movementType,
      'amount_cents': amountCents,
      'reason': reason,
      'description': description,
      'performed_by': performedBy,
      'movement_date': movementDate.toIso8601String(),
    };
  }
}
