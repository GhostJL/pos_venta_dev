import 'package:posventa/domain/repositories/inventory_repository.dart';

class DeleteInventory {
  final InventoryRepository repository;

  DeleteInventory(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteInventory(id);
  }
}
