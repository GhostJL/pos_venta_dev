import 'package:posventa/domain/repositories/inventory_repository.dart';

class DeleteInventoryByVariant {
  final InventoryRepository repository;

  DeleteInventoryByVariant(this.repository);

  Future<void> call(int productId, int warehouseId, int variantId) async {
    return await repository.deleteInventoryForProductVariant(
      productId,
      warehouseId,
      variantId,
    );
  }
}
