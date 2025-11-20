import 'package:posventa/domain/entities/purchase.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getPurchases();
  Future<Purchase?> getPurchaseById(int id);
  Future<int> createPurchase(Purchase purchase);
  Future<void> updatePurchase(Purchase purchase);
  Future<void> deletePurchase(int id);

  /// Receive a purchase and update inventory
  /// This critical process:
  /// 1. Updates purchase status to 'completed'
  /// 2. Sets received_date and received_by
  /// 3. Updates inventory stock (quantity_on_hand)
  /// 4. Creates inventory movements (Kardex)
  /// 5. Updates product cost_price_cents (Last Cost policy)
  Future<void> receivePurchase(int purchaseId, int receivedBy);
}
