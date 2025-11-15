import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/models/cash_session_model.dart';
import 'package:myapp/domain/entities/cash_session.dart';
import 'package:myapp/domain/repositories/cash_session_repository.dart';

class CashSessionRepositoryImpl implements CashSessionRepository {
  final DatabaseHelper _databaseHelper;
  final int _userId; // The ID of the authenticated user

  // The constructor now requires the user's ID.
  CashSessionRepositoryImpl(this._databaseHelper, this._userId);

  @override
  Future<CashSession> openSession(
    int warehouseId,
    int openingBalanceCents,
  ) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final data = {
      'warehouse_id': warehouseId,
      'user_id': _userId, // Use the stored user ID
      'opening_balance_cents': openingBalanceCents,
      'status': 'open',
      'opened_at': now.toIso8601String(),
    };
    final id = await db.insert('cash_sessions', data);
    return CashSession(
      id: id,
      warehouseId: warehouseId,
      userId: _userId, // Use the stored user ID
      openingBalanceCents: openingBalanceCents,
      status: 'open',
      openedAt: now,
    );
  }

  @override
  Future<CashSession> closeSession(
    int sessionId,
    int closingBalanceCents,
  ) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final data = {
      'closing_balance_cents': closingBalanceCents,
      'status': 'closed',
      'closed_at': now.toIso8601String(),
    };
    await db.update(
      'cash_sessions',
      data,
      where: 'id = ? AND user_id = ?', // Ensure user owns the session
      whereArgs: [sessionId, _userId],
    );
    final updatedData = await db.query(
      'cash_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    return CashSessionModel.fromMap(updatedData.first);
  }

  @override
  Future<CashSession?> getCurrentSession() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'cash_sessions',
      where: 'user_id = ? AND status = ?',
      whereArgs: [_userId, 'open'], // Use the stored user ID
      orderBy: 'opened_at DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return CashSessionModel.fromMap(result.first);
    }
    return null;
  }
}
