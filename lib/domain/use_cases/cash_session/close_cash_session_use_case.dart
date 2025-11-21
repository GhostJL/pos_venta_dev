import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/repositories/cash_session_repository.dart';

class CloseCashSessionUseCase {
  final CashSessionRepository _repository;

  CloseCashSessionUseCase(this._repository);

  Future<CashSession> call(int sessionId, int closingBalanceCents) async {
    // Validar que haya una sesión abierta
    final currentSession = await _repository.getCurrentSession();
    if (currentSession == null) {
      throw Exception('No hay una sesión de caja abierta para cerrar');
    }

    if (currentSession.id != sessionId) {
      throw Exception('El ID de sesión no coincide con la sesión actual');
    }

    // Validar monto de cierre
    if (closingBalanceCents < 0) {
      throw Exception('El monto de cierre no puede ser negativo');
    }

    return await _repository.closeSession(sessionId, closingBalanceCents);
  }
}
