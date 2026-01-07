import 'package:posventa/domain/repositories/inventory_repository.dart';

class ResetInventoryUseCase {
  final InventoryRepository _inventoryRepository;

  ResetInventoryUseCase(this._inventoryRepository);

  Future<void> call() async {
    return _inventoryRepository.resetAllInventory();
  }
}
