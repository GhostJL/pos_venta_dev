import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class AdjustInventory {
  final InventoryRepository _repository;

  AdjustInventory(this._repository);

  Future<void> call(InventoryMovement movement) async {
    return _repository.adjustInventory(movement);
  }
}
