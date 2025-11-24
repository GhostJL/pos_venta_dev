import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';

class AdjustInventoryBatchUseCase {
  final InventoryRepository repository;

  AdjustInventoryBatchUseCase(this.repository);

  Future<void> call(List<InventoryMovement> movements) async {
    if (movements.isEmpty) {
      return;
    }
    for (final movement in movements) {
      if (movement.movementType != MovementType.adjustment &&
          movement.movementType != MovementType.damage) {
        throw ArgumentError(
          'Invalid movement type for adjustment: ${movement.movementType}',
        );
      }
    }
    return await repository.adjustInventoryBatch(movements);
  }
}
