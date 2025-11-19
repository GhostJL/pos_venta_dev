import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class UpdateInventory {
  final InventoryRepository repository;

  UpdateInventory(this.repository);

  Future<void> call(Inventory inventory) async {
    return await repository.updateInventory(inventory);
  }
}
