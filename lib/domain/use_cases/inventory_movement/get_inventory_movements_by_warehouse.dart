import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';

class GetInventoryMovementsByWarehouse {
  final InventoryMovementRepository repository;

  GetInventoryMovementsByWarehouse(this.repository);

  Future<List<InventoryMovement>> call(int warehouseId) async {
    return await repository.getMovementsByWarehouse(warehouseId);
  }
}
