import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Use case to delete a purchase item
class DeletePurchaseItemUseCase {
  final PurchaseItemRepository repository;

  DeletePurchaseItemUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deletePurchaseItem(id);
  }
}
