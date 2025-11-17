import 'package:posventa/domain/entities/cash_movement.dart';

abstract class CashMovementRepository {
  Future<CashMovement> createMovement(
    int cashSessionId,
    String movementType,
    int amountCents,
    String reason, {
    String? description,
  });
  Future<List<CashMovement>> getMovementsBySession(int sessionId);
}
