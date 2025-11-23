enum TransactionType { entrada, salida }

class Transaction {
  final int? id;
  final int userId;
  final double amount;
  final TransactionType type;
  final DateTime timestamp;
  final String description;

  Transaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.timestamp,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type.name, // Use .name instead of describeEnum
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      amount: map['amount'] as double,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
      ), // Use .name for comparison
      timestamp: DateTime.parse(map['timestamp'] as String),
      description: map['description'] as String,
    );
  }
}
