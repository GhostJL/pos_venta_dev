
class CashMovement {
  final int? id;
  final int cashSessionId;
  final String movementType;
  final int amountCents;
  final String reason;
  final String? description;
  final int performedBy;
  final DateTime movementDate;

  CashMovement({
    this.id,
    required this.cashSessionId,
    required this.movementType,
    required this.amountCents,
    required this.reason,
    this.description,
    required this.performedBy,
    required this.movementDate,
  });
}
