import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Use case to get all purchase items
class GetPurchaseItemsUseCase {
  final PurchaseItemRepository repository;

  GetPurchaseItemsUseCase(this.repository);

  Future<List<PurchaseItem>> call() {
    return repository.getPurchaseItems();
  }
}
