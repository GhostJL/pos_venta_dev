import 'package:posventa/domain/entities/purchase.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getPurchases();
  Future<Purchase?> getPurchaseById(int id);
  Future<int> createPurchase(Purchase purchase);
  Future<void> updatePurchase(Purchase purchase);
  Future<void> deletePurchase(int id);
}
