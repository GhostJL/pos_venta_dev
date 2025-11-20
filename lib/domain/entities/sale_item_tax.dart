class SaleItemTax {
  final int? id;
  final int? saleItemId;
  final int taxRateId;
  final String taxName;
  final double taxRate;
  final int taxAmountCents;

  const SaleItemTax({
    this.id,
    this.saleItemId,
    required this.taxRateId,
    required this.taxName,
    required this.taxRate,
    required this.taxAmountCents,
  });
}
