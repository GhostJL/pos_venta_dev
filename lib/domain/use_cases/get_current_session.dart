
import 'package:myapp/domain/entities/cash_session.dart';
import 'package:myapp/domain/repositories/cash_session_repository.dart';

class GetCurrentSession {
  final CashSessionRepository repository;

  GetCurrentSession(this.repository);

  Future<CashSession?> call(int userId) {
    return repository.getCurrentSession(userId);
  }
}
