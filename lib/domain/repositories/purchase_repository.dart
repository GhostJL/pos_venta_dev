import 'package:posventa/domain/entities/purchase.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getPurchases();
  Future<Purchase?> getPurchaseById(int id);
  Future<int> createPurchase(Purchase purchase);
  Future<void> updatePurchase(Purchase purchase);
  Future<void> deletePurchase(int id);

  /// Receive a purchase (partial or complete)
  /// [purchaseId] - The ID of the purchase to receive
  /// [receivedQuantities] - Map of Item ID to Quantity Received
  /// [receivedBy] - The user ID who is receiving the purchase
  Future<void> receivePurchase(
    int purchaseId,
    Map<int, double> receivedQuantities,
    int receivedBy,
  );

  /// Cancel a purchase
  /// [purchaseId] - The ID of the purchase to cancel
  /// [userId] - The ID of the user cancelling the purchase
  Future<void> cancelPurchase(int purchaseId, int userId);
}
