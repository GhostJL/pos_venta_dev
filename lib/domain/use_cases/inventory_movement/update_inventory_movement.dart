import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';

class UpdateInventoryMovement {
  final InventoryMovementRepository repository;

  UpdateInventoryMovement(this.repository);

  Future<void> call(InventoryMovement movement) async {
    return await repository.updateMovement(movement);
  }
}
