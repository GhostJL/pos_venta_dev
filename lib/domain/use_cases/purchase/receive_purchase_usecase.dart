import 'package:posventa/domain/repositories/purchase_repository.dart';
import 'package:posventa/domain/entities/purchase_reception_item.dart';

/// Use case for receiving a purchase and updating inventory
/// This is the critical process that:
/// 1. Updates purchase status to 'completed'
/// 2. Sets received_date and received_by
/// 3. Updates inventory stock (quantity_on_hand)
/// 4. Creates inventory movements (Kardex)
/// 5. Updates product cost_price_cents (Last Cost policy)
class ReceivePurchaseUseCase {
  final PurchaseRepository repository;

  ReceivePurchaseUseCase(this.repository);

  /// Receive a purchase by ID
  /// [purchaseId] - The ID of the purchase to receive
  /// [items] - List of items to receive with their details
  /// [receivedBy] - The user ID who is receiving the purchase
  Future<void> call(
    int purchaseId,
    List<PurchaseReceptionItem> items,
    int receivedBy,
  ) async {
    return await repository.receivePurchase(purchaseId, items, receivedBy);
  }
}
