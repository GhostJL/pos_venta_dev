import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class GetInventoryByProduct {
  final InventoryRepository repository;

  GetInventoryByProduct(this.repository);

  Future<List<Inventory>> call(int productId) async {
    return await repository.getInventoryByProduct(productId);
  }
}
