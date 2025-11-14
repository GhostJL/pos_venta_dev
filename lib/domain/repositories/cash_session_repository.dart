import 'package:myapp/domain/entities/cash_session.dart';

abstract class CashSessionRepository {
  Future<CashSession> openSession(
    int warehouseId,
    int userId,
    int openingBalanceCents,
  );
  Future<CashSession> closeSession(int sessionId, int closingBalanceCents);
  Future<CashSession?> getCurrentSession(int userId);
}
