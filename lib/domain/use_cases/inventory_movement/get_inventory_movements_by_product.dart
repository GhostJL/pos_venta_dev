import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';

class GetInventoryMovementsByProduct {
  final InventoryMovementRepository repository;

  GetInventoryMovementsByProduct(this.repository);

  Future<List<InventoryMovement>> call(int productId, {int? variantId}) async {
    return await repository.getMovementsByProduct(
      productId,
      variantId: variantId,
    );
  }
}
