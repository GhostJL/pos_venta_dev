class PurchaseReceptionItem {
  final int itemId;
  final double quantity;
  final String lotNumber;
  final DateTime? expirationDate;

  const PurchaseReceptionItem({
    required this.itemId,
    required this.quantity,
    required this.lotNumber,
    this.expirationDate,
  });
}
