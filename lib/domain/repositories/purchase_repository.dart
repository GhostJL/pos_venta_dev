import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_reception_item.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getPurchases();
  Future<Purchase?> getPurchaseById(int id);
  Future<int> createPurchase(Purchase purchase);
  Future<void> updatePurchase(Purchase purchase);
  Future<void> deletePurchase(int id);

  /// Receive a purchase (partial or complete)
  /// [purchaseId] - The ID of the purchase to receive
  /// [items] - List of items to receive with their details
  /// [receivedBy] - The user ID who is receiving the purchase
  Future<void> receivePurchase(
    int purchaseId,
    List<PurchaseReceptionItem> items,
    int receivedBy,
  );

  /// Cancel a purchase
  /// [purchaseId] - The ID of the purchase to cancel
  /// [userId] - The ID of the user cancelling the purchase
  Future<void> cancelPurchase(int purchaseId, int userId);
}
