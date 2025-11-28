import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/cash_session_model.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/repositories/cash_session_repository.dart';

import 'package:posventa/data/models/cash_movement_model.dart';
import 'package:posventa/data/models/sale_payment_model.dart';
import 'package:posventa/domain/entities/cash_movement.dart';
import 'package:posventa/domain/entities/sale_payment.dart';

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

    return await db.transaction((txn) async {
      // 1. Obtener la sesión actual
      final sessionResult = await txn.query(
        'cash_sessions',
        where: 'id = ? AND user_id = ?',
        whereArgs: [sessionId, _userId],
      );

      if (sessionResult.isEmpty) {
        throw Exception('Sesión no encontrada o no pertenece al usuario');
      }

      final session = CashSessionModel.fromMap(sessionResult.first);

      // 2. Calcular efectivo esperado
      // 2a. Sumar pagos en efectivo de ventas realizadas durante la sesión
      final cashSalesResult = await txn.rawQuery(
        '''
        SELECT COALESCE(SUM(sp.amount_cents), 0) as total
        FROM sale_payments sp
        INNER JOIN sales s ON sp.sale_id = s.id
        WHERE s.cashier_id = ?
          AND sp.payment_method = 'Efectivo'
          AND s.sale_date >= ?
          AND s.sale_date <= ?
          AND s.status = 'completed'
      ''',
        [_userId, session.openedAt.toIso8601String(), now.toIso8601String()],
      );

      final cashFromSales = (cashSalesResult.first['total'] as int?) ?? 0;

      // 2b. Sumar movimientos de efectivo (entradas - salidas)
      final cashMovementsResult = await txn.rawQuery(
        '''
        SELECT COALESCE(SUM(amount_cents), 0) as total
        FROM cash_movements
        WHERE cash_session_id = ?
      ''',
        [sessionId],
      );

      final cashMovements = (cashMovementsResult.first['total'] as int?) ?? 0;

      // 3. Calcular balance esperado y diferencia
      final expectedBalanceCents =
          session.openingBalanceCents + cashFromSales + cashMovements;
      final differenceCents = closingBalanceCents - expectedBalanceCents;

      // 4. Actualizar la sesión
      await txn.update(
        'cash_sessions',
        {
          'closing_balance_cents': closingBalanceCents,
          'expected_balance_cents': expectedBalanceCents,
          'difference_cents': differenceCents,
          'status': 'closed',
          'closed_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [sessionId],
      );

      // 5. Registrar en audit_logs
      await txn.insert('audit_logs', {
        'table_name': 'cash_sessions',
        'record_id': sessionId,
        'action': 'close_session',
        'user_id': _userId,
        'username':
            'user_$_userId', // Se puede mejorar obteniendo el username real
        'new_values':
            '{"closing_balance_cents":$closingBalanceCents,'
            '"expected_balance_cents":$expectedBalanceCents,'
            '"difference_cents":$differenceCents}',
        'created_at': now.toIso8601String(),
      });

      // 6. Obtener y retornar la sesión actualizada
      final updatedData = await txn.query(
        'cash_sessions',
        where: 'id = ?',
        whereArgs: [sessionId],
      );

      return CashSessionModel.fromMap(updatedData.first);
    });
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

  @override
  Future<List<CashSession>> getSessions({
    int? userId,
    int? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }
    if (warehouseId != null) {
      whereClause += ' AND warehouse_id = ?';
      whereArgs.add(warehouseId);
    }
    if (startDate != null) {
      whereClause += ' AND opened_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClause += ' AND opened_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery('''
      SELECT cs.*, u.username, u.first_name, u.last_name
      FROM cash_sessions cs
      LEFT JOIN users u ON cs.user_id = u.id
      WHERE $whereClause
      ORDER BY cs.opened_at DESC
      ''', whereArgs);

    return result.map((e) => CashSessionModel.fromMap(e)).toList();
  }

  @override
  Future<List<CashMovement>> getSessionMovements(int sessionId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'cash_movements',
      where: 'cash_session_id = ?',
      whereArgs: [sessionId],
    );
    return result.map((e) => CashMovementModel.fromMap(e)).toList();
  }

  @override
  Future<List<CashMovement>> getAllMovements({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += ' AND movement_date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClause += ' AND movement_date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.query(
      'cash_movements',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'movement_date DESC',
    );
    return result.map((e) => CashMovementModel.fromMap(e)).toList();
  }

  @override
  Future<List<SalePayment>> getSessionPayments(int sessionId) async {
    final db = await _databaseHelper.database;
    final sessionResult = await db.query(
      'cash_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    if (sessionResult.isEmpty) return [];
    final session = CashSessionModel.fromMap(sessionResult.first);

    final endTime =
        session.closedAt?.toIso8601String() ?? DateTime.now().toIso8601String();

    final result = await db.rawQuery(
      '''
        SELECT sp.* 
        FROM sale_payments sp
        JOIN sales s ON sp.sale_id = s.id
        WHERE s.cashier_id = ?
        AND s.sale_date >= ?
        AND s.sale_date <= ?
        AND sp.payment_method = 'Efectivo' 
      ''',
      [session.userId, session.openedAt.toIso8601String(), endTime],
    );

    return result.map((e) => SalePaymentModel.fromJson(e)).toList();
  }

  @override
  Future<List<SalePayment>> getAllSessionPayments(int sessionId) async {
    final db = await _databaseHelper.database;
    final sessionResult = await db.query(
      'cash_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    if (sessionResult.isEmpty) return [];
    final session = CashSessionModel.fromMap(sessionResult.first);

    final endTime =
        session.closedAt?.toIso8601String() ?? DateTime.now().toIso8601String();

    final result = await db.rawQuery(
      '''
        SELECT sp.* 
        FROM sale_payments sp
        JOIN sales s ON sp.sale_id = s.id
        WHERE s.cashier_id = ?
        AND s.sale_date >= ?
        AND s.sale_date <= ?
        AND s.status = 'completed'
      ''',
      [session.userId, session.openedAt.toIso8601String(), endTime],
    );

    return result.map((e) => SalePaymentModel.fromJson(e)).toList();
  }
}
