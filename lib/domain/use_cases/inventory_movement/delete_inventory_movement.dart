import 'package:posventa/domain/repositories/inventory_movement_repository.dart';

class DeleteInventoryMovement {
  final InventoryMovementRepository repository;

  DeleteInventoryMovement(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteMovement(id);
  }
}
