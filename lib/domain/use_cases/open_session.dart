import 'package:myapp/domain/entities/cash_session.dart';
import 'package:myapp/domain/repositories/cash_session_repository.dart';

class OpenSession {
  final CashSessionRepository repository;

  OpenSession(this.repository);

  Future<CashSession> call(
    int warehouseId,
    int openingBalanceCents,
  ) {
    return repository.openSession(warehouseId, openingBalanceCents);
  }
}
