import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

/// Utility class for purchase-related calculations
class PurchaseCalculations {
  /// Calculates subtotal in cents from unit cost and quantity
  static int calculateSubtotalCents(int unitCostCents, double quantity) {
    return (unitCostCents * quantity).round();
  }

  /// Calculates tax in cents from subtotal and tax rate
  static int calculateTaxCents(int subtotalCents, double taxRate) {
    return (subtotalCents * taxRate).round();
  }

  /// Calculates total in cents from subtotal and tax
  static int calculateTotalCents(int subtotalCents, int taxCents) {
    return subtotalCents + taxCents;
  }

  /// Creates a PurchaseItem from product and form data
  /// If existingItem is provided, it will preserve its id and other metadata
  static PurchaseItem createPurchaseItem({
    required Product product,
    required double quantity,
    required double unitCost,
    PurchaseItem? existingItem,
  }) {
    final unitCostCents = (unitCost * 100).round();
    final subtotalCents = calculateSubtotalCents(unitCostCents, quantity);

    // For now, purchases don't have tax (or it's 0)
    // This can be modified if tax logic is needed
    const taxCents = 0;
    final totalCents = calculateTotalCents(subtotalCents, taxCents);

    return PurchaseItem(
      id: existingItem?.id,
      purchaseId: existingItem?.purchaseId,
      productId: product.id!,
      productName: product.name,
      quantity: quantity,
      unitOfMeasure: product.unitOfMeasure,
      unitCostCents: unitCostCents,
      subtotalCents: subtotalCents,
      taxCents: taxCents,
      totalCents: totalCents,
      lotNumber: existingItem?.lotNumber,
      expirationDate: existingItem?.expirationDate,
      createdAt: existingItem?.createdAt ?? DateTime.now(),
    );
  }
}
