import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/repositories/cash_session_repository.dart';

class GetCurrentCashSessionUseCase {
  final CashSessionRepository _repository;

  GetCurrentCashSessionUseCase(this._repository);

  Future<CashSession?> call() async {
    return await _repository.getCurrentSession();
  }
}
