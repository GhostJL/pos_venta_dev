import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Use case to get purchase items by product ID
/// Useful for tracking purchase history of a specific product in POS
class GetPurchaseItemsByProductIdUseCase {
  final PurchaseItemRepository repository;

  GetPurchaseItemsByProductIdUseCase(this.repository);

  Future<List<PurchaseItem>> call(int productId) {
    return repository.getPurchaseItemsByProductId(productId);
  }
}
