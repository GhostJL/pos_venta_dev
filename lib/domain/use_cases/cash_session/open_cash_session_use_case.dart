import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/repositories/cash_session_repository.dart';

class OpenCashSessionUseCase {
  final CashSessionRepository _repository;

  OpenCashSessionUseCase(this._repository);

  Future<CashSession> call(int warehouseId, int openingBalanceCents) async {
    // Verificar que no haya una sesión abierta
    final currentSession = await _repository.getCurrentSession();
    if (currentSession != null) {
      throw Exception(
        'Ya existe una sesión de caja abierta. Debe cerrarla antes de abrir una nueva.',
      );
    }

    // Validar monto de apertura
    if (openingBalanceCents < 0) {
      throw Exception('El monto de apertura no puede ser negativo');
    }

    return await _repository.openSession(warehouseId, openingBalanceCents);
  }
}
