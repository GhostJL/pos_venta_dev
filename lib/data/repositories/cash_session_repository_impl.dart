import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/cash_session_model.dart';
import 'package:posventa/data/models/cash_movement_model.dart';
import 'package:posventa/data/models/sale_payment_model.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/entities/cash_movement.dart';
import 'package:posventa/domain/entities/sale_payment.dart';
import 'package:posventa/domain/repositories/cash_session_repository.dart';

class CashSessionRepositoryImpl implements CashSessionRepository {
  final drift_db.AppDatabase db;
  final int _userId;

  CashSessionRepositoryImpl(this.db, this._userId);

  @override
  Future<CashSession> openSession(
    int warehouseId,
    int openingBalanceCents,
  ) async {
    final now = DateTime.now();
    final companion = drift_db.CashSessionsCompanion.insert(
      warehouseId: warehouseId,
      userId: _userId,
      openingBalanceCents: openingBalanceCents,
      status: Value('open'),
      openedAt: Value(now),
    );

    final id = await db.into(db.cashSessions).insert(companion);

    return CashSession(
      id: id,
      warehouseId: warehouseId,
      userId: _userId,
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
    final now = DateTime.now();

    return await db.transaction(() async {
      // 1. Get Session
      final sessionRow =
          await (db.select(db.cashSessions)..where(
                (t) => t.id.equals(sessionId) & t.userId.equals(_userId),
              ))
              .getSingleOrNull();

      if (sessionRow == null) {
        throw Exception('Sesión no encontrada o no pertenece al usuario');
      }

      // 2. Calculate Expected Cash
      // 2a. Cash from Sales (Sum sale_payments where method='Efectivo' and sale.cashier_id = user within session time)
      // We need to join SalePayments with Sales to check cashier and date
      final salesCashQuery =
          db.selectOnly(db.salePayments).join([
              innerJoin(
                db.sales,
                db.sales.id.equalsExp(db.salePayments.saleId),
              ),
            ])
            ..addColumns([db.salePayments.amountCents.sum()])
            ..where(
              db.sales.cashierId.equals(_userId) &
                  db.salePayments.paymentMethod.equals('Efectivo') &
                  db.sales.saleDate.isBiggerOrEqualValue(sessionRow.openedAt) &
                  db.sales.saleDate.isSmallerOrEqualValue(now),
            );

      final salesCashResult = await salesCashQuery.getSingle();
      final cashFromSales =
          salesCashResult.read(db.salePayments.amountCents.sum()) ?? 0;

      // 2b. Cash Movements
      final movementsQuery = db.select(db.cashMovements)
        ..where((t) => t.cashSessionId.equals(sessionId));
      final movements = await movementsQuery.get();

      int movementsTotal = 0;
      for (final m in movements) {
        if (m.movementType == 'entry') {
          movementsTotal += m.amountCents;
        } else {
          movementsTotal -= m.amountCents;
        }
      }

      // 3. Expected Balance
      final expectedBalanceCents =
          sessionRow.openingBalanceCents + cashFromSales + movementsTotal;
      final differenceCents = closingBalanceCents - expectedBalanceCents;

      // 4. Update Session
      await (db.update(
        db.cashSessions,
      )..where((t) => t.id.equals(sessionId))).write(
        drift_db.CashSessionsCompanion(
          closingBalanceCents: Value(closingBalanceCents),
          expectedBalanceCents: Value(expectedBalanceCents),
          differenceCents: Value(differenceCents),
          status: Value('closed'),
          closedAt: Value(now),
        ),
      );

      // 5. Audit Log (Optional but good practice if table exists in Drift)
      // I don't recall seeing AuditLogs in tables.dart. Let's check.
      // Assuming AuditLogs might not exist or I didn't verify it.
      // If table exist in db (it wasn't in tables.dart listing step 296?), I should skip or add it.
      // Looking at step 296, I do NOT see 'AuditLogs' table. I see Users, AppMeta, Transactions, Catalog tables, Inventory, Party, Sales, Purchase.
      // So I will SKIP audit logging for now as Table doesn't seem to be in Drift schema yet.

      return CashSession(
        id: sessionRow.id,
        warehouseId: sessionRow.warehouseId,
        userId: sessionRow.userId,
        openingBalanceCents: sessionRow.openingBalanceCents,
        status: 'closed',
        openedAt: sessionRow.openedAt,
        closedAt: now,
        closingBalanceCents: closingBalanceCents,
        expectedBalanceCents: expectedBalanceCents,
        differenceCents: differenceCents,
      );
    });
  }

  @override
  Future<CashSession?> getCurrentSession() async {
    final row =
        await (db.select(db.cashSessions)
              ..where((t) => t.userId.equals(_userId) & t.status.equals('open'))
              ..orderBy([(t) => OrderingTerm.desc(t.openedAt)])
              ..limit(1))
            .getSingleOrNull();

    if (row != null) {
      return CashSessionModel(
        id: row.id,
        warehouseId: row.warehouseId,
        userId: row.userId,
        openingBalanceCents: row.openingBalanceCents,
        status: row.status,
        openedAt: row.openedAt,
        closedAt: row.closedAt,
        closingBalanceCents: row.closingBalanceCents,
        expectedBalanceCents: row.expectedBalanceCents,
        differenceCents: row.differenceCents,
      );
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
    final q = db.select(db.cashSessions).join([
      leftOuterJoin(db.users, db.users.id.equalsExp(db.cashSessions.userId)),
    ]);

    if (userId != null) {
      q.where(db.cashSessions.userId.equals(userId));
    }
    if (warehouseId != null) {
      q.where(db.cashSessions.warehouseId.equals(warehouseId));
    }
    if (startDate != null) {
      q.where(db.cashSessions.openedAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      q.where(db.cashSessions.openedAt.isSmallerOrEqualValue(endDate));
    }

    q.orderBy([OrderingTerm.desc(db.cashSessions.openedAt)]);

    final rows = await q.get();
    return rows.map((row) {
      final sessionRow = row.readTable(db.cashSessions);
      final userRow = row.readTableOrNull(db.users);

      return CashSessionModel(
        id: sessionRow.id,
        warehouseId: sessionRow.warehouseId,
        userId: sessionRow.userId,
        openingBalanceCents: sessionRow.openingBalanceCents,
        status: sessionRow.status,
        openedAt: sessionRow.openedAt,
        closedAt: sessionRow.closedAt,
        closingBalanceCents: sessionRow.closingBalanceCents,
        expectedBalanceCents: sessionRow.expectedBalanceCents,
        differenceCents: sessionRow.differenceCents,
        userName: (userRow != null)
            ? ((userRow.firstName != null && userRow.firstName!.isNotEmpty)
                  ? '${userRow.firstName} ${userRow.lastName ?? ''}'.trim()
                  : userRow.username)
            : null,
      );
    }).toList();
  }

  @override
  Future<List<CashMovement>> getSessionMovements(int sessionId) async {
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

  @override
  Future<List<CashMovement>> getAllMovements({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final q = db.select(db.cashMovements);

    if (startDate != null) {
      q.where((t) => t.movementDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      q.where((t) => t.movementDate.isSmallerOrEqualValue(endDate));
    }

    q.orderBy([(t) => OrderingTerm.desc(t.movementDate)]);

    final rows = await q.get();
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

  @override
  Future<List<SalePayment>> getSessionPayments(int sessionId) async {
    final session = await (db.select(
      db.cashSessions,
    )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (session == null) return [];

    final endTime = session.closedAt ?? DateTime.now();

    final q =
        db.select(db.salePayments).join([
          innerJoin(db.sales, db.sales.id.equalsExp(db.salePayments.saleId)),
        ])..where(
          db.sales.cashierId.equals(session.userId) &
              db.sales.saleDate.isBetweenValues(session.openedAt, endTime) &
              db.salePayments.paymentMethod.equals('Efectivo'),
        );

    final rows = await q.get();
    return rows.map((row) {
      final p = row.readTable(db.salePayments);
      return SalePaymentModel(
        id: p.id,
        saleId: p.saleId,
        paymentMethod: p.paymentMethod,
        amountCents: p.amountCents,
        referenceNumber: p.referenceNumber,
        paymentDate: p.paymentDate,
        receivedBy: p.receivedBy,
      );
    }).toList();
  }

  @override
  Future<List<SalePayment>> getAllSessionPayments(int sessionId) async {
    final session = await (db.select(
      db.cashSessions,
    )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (session == null) return [];

    final endTime = session.closedAt ?? DateTime.now();

    final q =
        db.select(db.salePayments).join([
          innerJoin(db.sales, db.sales.id.equalsExp(db.salePayments.saleId)),
        ])..where(
          db.sales.cashierId.equals(session.userId) &
              db.sales.saleDate.isBetweenValues(session.openedAt, endTime),
        );

    final rows = await q.get();
    return rows.map((row) {
      final p = row.readTable(db.salePayments);
      return SalePaymentModel(
        id: p.id,
        saleId: p.saleId,
        paymentMethod: p.paymentMethod,
        amountCents: p.amountCents,
        referenceNumber: p.referenceNumber,
        paymentDate: p.paymentDate,
        receivedBy: p.receivedBy,
      );
    }).toList();
  }
}
