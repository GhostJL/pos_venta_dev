class SaleReturnItem {
  final int? id;
  final int saleReturnId;
  final int saleItemId;
  final int productId;
  final double quantity;
  final int unitPriceCents;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final String? reason;
  final DateTime createdAt;

  // Optional fields for display
  final String? productName;
  final String? productCode;

  const SaleReturnItem({
    this.id,
    required this.saleReturnId,
    required this.saleItemId,
    required this.productId,
    required this.quantity,
    required this.unitPriceCents,
    required this.subtotalCents,
    this.taxCents = 0,
    required this.totalCents,
    this.reason,
    required this.createdAt,
    this.productName,
    this.productCode,
  });

  double get unitPrice => unitPriceCents / 100.0;
  double get subtotal => subtotalCents / 100.0;
  double get tax => taxCents / 100.0;
  double get total => totalCents / 100.0;
}
