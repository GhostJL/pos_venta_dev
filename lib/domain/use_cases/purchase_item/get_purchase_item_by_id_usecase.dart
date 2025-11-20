import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

/// Use case to get a single purchase item by ID
class GetPurchaseItemByIdUseCase {
  final PurchaseItemRepository repository;

  GetPurchaseItemByIdUseCase(this.repository);

  Future<PurchaseItem?> call(int id) {
    return repository.getPurchaseItemById(id);
  }
}
