import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';

class GetAllInventoryMovements {
  final InventoryMovementRepository repository;

  GetAllInventoryMovements(this.repository);

  Future<List<InventoryMovement>> call() async {
    return await repository.getAllMovements();
  }
}
