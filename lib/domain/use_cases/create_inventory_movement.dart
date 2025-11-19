import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';

class CreateInventoryMovement {
  final InventoryMovementRepository repository;

  CreateInventoryMovement(this.repository);

  Future<void> call(InventoryMovement movement) async {
    return await repository.createMovement(movement);
  }
}
