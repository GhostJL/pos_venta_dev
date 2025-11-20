import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Use case to create a new purchase item
class CreatePurchaseItemUseCase {
  final PurchaseItemRepository repository;

  CreatePurchaseItemUseCase(this.repository);

  Future<int> call(PurchaseItem item) {
    return repository.createPurchaseItem(item);
  }
}
