import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/repositories/cash_session_repository.dart';

class GetCurrentSession {
  final CashSessionRepository repository;

  GetCurrentSession(this.repository);

  Future<CashSession?> call() {
    return repository.getCurrentSession();
  }
}
