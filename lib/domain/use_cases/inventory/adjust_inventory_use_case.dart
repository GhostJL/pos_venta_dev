import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class AdjustInventoryUseCase {
  final InventoryRepository repository;

  AdjustInventoryUseCase(this.repository);

  Future<void> call(InventoryMovement movement) async {
    if (movement.movementType != MovementType.adjustment &&
        movement.movementType != MovementType.damage) {
      throw ArgumentError('Invalid movement type for adjustment');
    }
    return await repository.adjustInventory(movement);
  }
}
