import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class GetAllInventory {
  final InventoryRepository repository;

  GetAllInventory(this.repository);

  Future<List<Inventory>> call() async {
    return await repository.getAllInventory();
  }

  Stream<List<Inventory>> stream() {
    return repository.getAllInventoryStream();
  }
}
