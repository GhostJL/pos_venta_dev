import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Use case to get purchase items by purchase ID
class GetPurchaseItemsByPurchaseIdUseCase {
  final PurchaseItemRepository repository;

  GetPurchaseItemsByPurchaseIdUseCase(this.repository);

  Future<List<PurchaseItem>> call(int purchaseId) {
    return repository.getPurchaseItemsByPurchaseId(purchaseId);
  }
}
