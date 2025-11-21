import 'package:posventa/domain/repositories/inventory_repository.dart';

class TransferInventoryUseCase {
  final InventoryRepository repository;

  TransferInventoryUseCase(this.repository);

  Future<void> call({
    required int fromWarehouseId,
    required int toWarehouseId,
    required int productId,
    required double quantity,
    required int userId,
    String? reason,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }
    if (fromWarehouseId == toWarehouseId) {
      throw ArgumentError(
        'Source and destination warehouses must be different',
      );
    }

    return await repository.transferInventory(
      fromWarehouseId: fromWarehouseId,
      toWarehouseId: toWarehouseId,
      productId: productId,
      quantity: quantity,
      userId: userId,
      reason: reason,
    );
  }
}
