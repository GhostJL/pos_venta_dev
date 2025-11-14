
import 'package:myapp/domain/entities/cash_movement.dart';
import 'package:myapp/domain/repositories/cash_movement_repository.dart';

class GetMovementsBySession {
  final CashMovementRepository repository;

  GetMovementsBySession(this.repository);

  Future<List<CashMovement>> call(int sessionId) {
    return repository.getMovementsBySession(sessionId);
  }
}
