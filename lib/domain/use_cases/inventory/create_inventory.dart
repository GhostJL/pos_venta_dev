import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class CreateInventory {
  final InventoryRepository repository;

  CreateInventory(this.repository);

  Future<void> call(Inventory inventory) async {
    return await repository.createInventory(inventory);
  }
}
