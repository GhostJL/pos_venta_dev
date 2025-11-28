class CashSession {
  final int? id;
  final int warehouseId;
  final int userId;
  final int openingBalanceCents;
  final int? closingBalanceCents;
  final int? expectedBalanceCents;
  final int? differenceCents;
  final String status;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String? notes;
  final String? userName;

  CashSession({
    this.id,
    required this.warehouseId,
    required this.userId,
    required this.openingBalanceCents,
    this.closingBalanceCents,
    this.expectedBalanceCents,
    this.differenceCents,
    required this.status,
    required this.openedAt,
    this.closedAt,
    this.notes,
    this.userName,
  });

  int get currentBalanceCents {
    return openingBalanceCents + (expectedBalanceCents ?? 0);
  }
}
