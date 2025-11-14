
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/models/cash_session_model.dart';
import 'package:myapp/domain/entities/cash_session.dart';
import 'package:myapp/domain/repositories/cash_session_repository.dart';

class CashSessionRepositoryImpl implements CashSessionRepository {
  final DatabaseHelper _databaseHelper;

  CashSessionRepositoryImpl(this._databaseHelper);

  @override
  Future<CashSession> openSession(int warehouseId, int userId, int openingBalanceCents) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final data = {
      'warehouse_id': warehouseId,
      'user_id': userId,
      'opening_balance_cents': openingBalanceCents,
      'status': 'open',
      'opened_at': now.toIso8601String(),
    };
    final id = await db.insert('cash_sessions', data);
    return CashSession(
      id: id,
      warehouseId: warehouseId,
      userId: userId,
      openingBalanceCents: openingBalanceCents,
      status: 'open',
      openedAt: now,
    );
  }

  @override
  Future<CashSession> closeSession(int sessionId, int closingBalanceCents) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    // You would typically calculate expected_balance_cents and difference_cents here
    final data = {
      'closing_balance_cents': closingBalanceCents,
      'status': 'closed',
      'closed_at': now.toIso8601String(),
    };
    await db.update('cash_sessions', data, where: 'id = ?', whereArgs: [sessionId]);
    final updatedData = await db.query('cash_sessions', where: 'id = ?', whereArgs: [sessionId]);
    return CashSessionModel.fromMap(updatedData.first);
  }

  @override
  Future<CashSession?> getCurrentSession(int userId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'cash_sessions',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'open'],
      orderBy: 'opened_at DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return CashSessionModel.fromMap(result.first);
    }
    return null;
  }
}
