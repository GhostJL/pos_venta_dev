import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';

class GetInventoryMovementsByDateRange {
  final InventoryMovementRepository repository;

  GetInventoryMovementsByDateRange(this.repository);

  Future<List<InventoryMovement>> call(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await repository.getMovementsByDateRange(startDate, endDate);
  }
}
