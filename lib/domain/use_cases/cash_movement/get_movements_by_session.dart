import 'package:posventa/domain/entities/cash_movement.dart';
import 'package:posventa/domain/repositories/cash_movement_repository.dart';

class GetMovementsBySession {
  final CashMovementRepository repository;

  GetMovementsBySession(this.repository);

  Future<List<CashMovement>> call(int sessionId) {
    return repository.getMovementsBySession(sessionId);
  }
}
