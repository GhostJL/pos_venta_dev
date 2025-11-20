import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Use case to update an existing purchase item
class UpdatePurchaseItemUseCase {
  final PurchaseItemRepository repository;

  UpdatePurchaseItemUseCase(this.repository);

  Future<void> call(PurchaseItem item) {
    return repository.updatePurchaseItem(item);
  }
}
