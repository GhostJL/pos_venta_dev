import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/repositories/cash_session_repository.dart';

class CloseSession {
  final CashSessionRepository repository;

  CloseSession(this.repository);

  Future<CashSession> call(int sessionId, int closingBalanceCents) {
    return repository.closeSession(sessionId, closingBalanceCents);
  }
}
