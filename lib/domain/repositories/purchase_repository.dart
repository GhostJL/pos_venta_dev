import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_reception_transaction.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getPurchases({
    String? query,
    PurchaseStatus? status,
    int? limit,
    int? offset,
  });

  Future<int> countPurchases({String? query, PurchaseStatus? status});
  Future<Purchase?> getPurchaseById(int id);
  Future<int> createPurchase(Purchase purchase);
  Future<void> updatePurchase(Purchase purchase);
  Future<void> deletePurchase(int id);

  /// Execute a purchase reception transaction
  /// [transaction] - The fully prepared transaction data
  Future<void> executePurchaseReception(
    PurchaseReceptionTransaction transaction,
  );

  /// Cancel a purchase
  /// [purchaseId] - The ID of the purchase to cancel
  /// [userId] - The ID of the user cancelling the purchase
  Future<void> cancelPurchase(int purchaseId, int userId);
}
