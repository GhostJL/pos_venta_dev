import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/cash_movement_model.dart';
import 'package:posventa/domain/entities/cash_movement.dart';
import 'package:posventa/domain/repositories/cash_movement_repository.dart';

class CashMovementRepositoryImpl implements CashMovementRepository {
  final drift_db.AppDatabase db;
  final int userId;

  CashMovementRepositoryImpl(this.db, this.userId);

  @override
  Future<CashMovement> createMovement(
    int cashSessionId,
    String movementType,
    int amountCents,
    String reason, {
    String? description,
  }) async {
    final now = DateTime.now();
    final companion = drift_db.CashMovementsCompanion.insert(
      cashSessionId: cashSessionId,
      movementType: movementType,
      amountCents: amountCents,
      reason: reason,
      description: Value(description),
      performedBy: userId,
      movementDate: Value(now),
    );

    final id = await db.into(db.cashMovements).insert(companion);

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
    final rows = await (db.select(
      db.cashMovements,
    )..where((t) => t.cashSessionId.equals(sessionId))).get();
    return rows
        .map(
          (row) => CashMovementModel(
            id: row.id,
            cashSessionId: row.cashSessionId,
            movementType: row.movementType,
            amountCents: row.amountCents,
            reason: row.reason,
            description: row.description,
            performedBy: row.performedBy,
            movementDate: row.movementDate,
          ),
        )
        .toList();
  }
}
