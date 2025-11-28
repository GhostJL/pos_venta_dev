import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/entities/cash_movement.dart';
import 'package:posventa/domain/entities/sale_payment.dart';

abstract class CashSessionRepository {
  Future<CashSession> openSession(int warehouseId, int openingBalanceCents);
  Future<CashSession> closeSession(int sessionId, int closingBalanceCents);
  Future<CashSession?> getCurrentSession();
  Future<List<CashSession>> getSessions({
    int? userId,
    int? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<CashMovement>> getSessionMovements(int sessionId);
  Future<List<CashMovement>> getAllMovements({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<SalePayment>> getSessionPayments(int sessionId);
  Future<List<SalePayment>> getAllSessionPayments(int sessionId);
}
