class SalePayment {
  final int? id;
  final int? saleId;
  final String paymentMethod;
  final int amountCents;
  final String? referenceNumber;
  final DateTime paymentDate;
  final int receivedBy;

  const SalePayment({
    this.id,
    this.saleId,
    required this.paymentMethod,
    required this.amountCents,
    this.referenceNumber,
    required this.paymentDate,
    required this.receivedBy,
  });

  double get amount => amountCents / 100.0;
}
