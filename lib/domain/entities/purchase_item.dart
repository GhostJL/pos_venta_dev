class PurchaseItem {
  final int? id;
  final int? purchaseId;
  final int productId;
  final String? productName;
  final double quantity;
  final String unitOfMeasure;
  final int unitCostCents;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final String? lotNumber;
  final DateTime? expirationDate;
  final DateTime createdAt;

  const PurchaseItem({
    this.id,
    this.purchaseId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitOfMeasure,
    required this.unitCostCents,
    required this.subtotalCents,
    this.taxCents = 0,
    required this.totalCents,
    this.lotNumber,
    this.expirationDate,
    required this.createdAt,
  });

  double get unitCost => unitCostCents / 100.0;
  double get subtotal => subtotalCents / 100.0;
  double get tax => taxCents / 100.0;
  double get total => totalCents / 100.0;
}
