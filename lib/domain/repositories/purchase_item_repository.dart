import 'package:posventa/domain/entities/purchase_item.dart';

/// Repository interface for Purchase Item operations
/// Follows clean architecture principles
abstract class PurchaseItemRepository {
  /// Get all purchase items
  Future<List<PurchaseItem>> getPurchaseItems();

  /// Get purchase items by purchase ID
  Future<List<PurchaseItem>> getPurchaseItemsByPurchaseId(int purchaseId);

  /// Get a single purchase item by ID
  Future<PurchaseItem?> getPurchaseItemById(int id);

  /// Get purchase items by product ID (useful for tracking product purchase history)
  Future<List<PurchaseItem>> getPurchaseItemsByProductId(int productId);

  /// Create a new purchase item
  Future<int> createPurchaseItem(PurchaseItem item);

  /// Update an existing purchase item
  Future<void> updatePurchaseItem(PurchaseItem item);

  /// Delete a purchase item
  Future<void> deletePurchaseItem(int id);

  /// Get purchase items within a date range (for reporting)
  Future<List<PurchaseItem>> getPurchaseItemsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get purchase items with low stock alert (items that need reordering)
  Future<List<PurchaseItem>> getRecentPurchaseItems({int limit = 50});
}
