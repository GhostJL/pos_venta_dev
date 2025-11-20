import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Use case to get recent purchase items
/// Useful for POS dashboard and quick access
class GetRecentPurchaseItemsUseCase {
  final PurchaseItemRepository repository;

  GetRecentPurchaseItemsUseCase(this.repository);

  Future<List<PurchaseItem>> call({int limit = 50}) {
    return repository.getRecentPurchaseItems(limit: limit);
  }
}
