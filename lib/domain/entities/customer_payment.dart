class CustomerPayment {
  final int? id;
  final int customerId;
  final double amount;
  final String paymentMethod;
  final String? reference;
  final DateTime paymentDate;
  final int processedBy;
  final String? processedByName;
  final String? notes;
  final DateTime createdAt;

  CustomerPayment({
    this.id,
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    this.reference,
    required this.paymentDate,
    required this.processedBy,
    this.processedByName,
    this.notes,
    required this.createdAt,
  });
}
