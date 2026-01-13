enum TransactionType { entrada, salida }

class Transaction {
  final int? id;
  final int userId;
  final int amountCents;
  final TransactionType type;
  final DateTime timestamp;
  final String description;

  double get amount => amountCents / 100.0;

  Transaction({
    this.id,
    required this.userId,
    required this.amountCents,
    required this.type,
    required this.timestamp,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount_cents': amountCents,
      'type': type.name, // Use .name instead of describeEnum
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      amountCents: map['amount_cents'] as int,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
      ), // Use .name for comparison
      timestamp: DateTime.parse(map['timestamp'] as String),
      description: map['description'] as String,
    );
  }
}
