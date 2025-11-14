
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/models/cash_movement_model.dart';
import 'package:myapp/domain/entities/cash_movement.dart';
import 'package:myapp/domain/repositories/cash_movement_repository.dart';

class CashMovementRepositoryImpl implements CashMovementRepository {
  final DatabaseHelper _databaseHelper;
  final int userId; // Assuming the user id is available here

  CashMovementRepositoryImpl(this._databaseHelper, this.userId);

  @override
  Future<CashMovement> createMovement(int cashSessionId, String movementType, int amountCents, String reason, {String? description}) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final data = {
      'cash_session_id': cashSessionId,
      'movement_type': movementType,
      'amount_cents': amountCents,
      'reason': reason,
      'description': description,
      'performed_by': userId,
      'movement_date': now.toIso8601String(),
    };
    final id = await db.insert('cash_movements', data);
    return CashMovement(
      id: id,
      cashSessionId: cashSessionId,
      movementType: movementType,
      amountCents: amountCents,
      reason: reason,
      description: description,
      performedBy: userId,
      movementDate: now,
    );
  }

  @override
  Future<List<CashMovement>> getMovementsBySession(int sessionId) async {
    final db = await _databaseHelper.database;
    final result = await db.query('cash_movements', where: 'cash_session_id = ?', whereArgs: [sessionId]);
    return result.map((map) => CashMovementModel.fromMap(map)).toList();
  }
}
