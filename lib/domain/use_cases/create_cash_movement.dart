
import 'package:myapp/domain/entities/cash_movement.dart';
import 'package:myapp/domain/repositories/cash_movement_repository.dart';

class CreateCashMovement {
  final CashMovementRepository repository;

  CreateCashMovement(this.repository);

  Future<CashMovement> call(int cashSessionId, String movementType, int amountCents, String reason, {String? description}) {
    return repository.createMovement(cashSessionId, movementType, amountCents, reason, description: description);
  }
}
