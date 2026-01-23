import 'package:posventa/domain/repositories/inventory_repository.dart';

class ResetInventoryUseCase {
  final InventoryRepository _inventoryRepository;

  ResetInventoryUseCase(this._inventoryRepository);

  Future<void> call() async {
    // Reconcile instead of Reset for safety
    return _inventoryRepository.reconcileInventory();
  }
}
