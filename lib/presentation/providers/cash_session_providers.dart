import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:posventa/domain/entities/cash_movement.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/entities/sale_payment.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/domain/entities/warehouse.dart';

part 'cash_session_providers.g.dart';

// Repository Provider
// Repository provider moved to sale_di.dart

@riverpod
Future<List<Warehouse>> warehouseList(Ref ref) async {
  final useCase = ref.watch(getAllWarehousesProvider);
  return useCase();
}

// Filter Classes
class CashSessionFilter {
  final int? userId;
  final int? warehouseId;
  final DateTime? startDate;
  final DateTime? endDate;

  CashSessionFilter({
    this.userId,
    this.warehouseId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CashSessionFilter &&
        other.userId == userId &&
        other.warehouseId == warehouseId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        warehouseId.hashCode ^
        startDate.hashCode ^
        endDate.hashCode;
  }
}

class CashMovementFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? userId;

  CashMovementFilter({this.startDate, this.endDate, this.userId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CashMovementFilter &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

// Providers

@riverpod
Future<List<CashSession>> cashSessionList(
  Ref ref,
  CashSessionFilter filter,
) async {
  final repo = ref.watch(cashSessionRepositoryProvider);
  return repo.getSessions(
    userId: filter.userId,
    warehouseId: filter.warehouseId,
    startDate: filter.startDate,
    endDate: filter.endDate,
  );
}

@riverpod
Future<List<CashMovement>> cashSessionMovements(Ref ref, int sessionId) async {
  final repo = ref.watch(cashSessionRepositoryProvider);
  return repo.getSessionMovements(sessionId);
}

@riverpod
Future<List<SalePayment>> cashSessionPayments(Ref ref, int sessionId) async {
  final repo = ref.watch(cashSessionRepositoryProvider);
  return repo.getSessionPayments(sessionId);
}

@riverpod
Future<List<CashMovement>> allCashMovements(
  Ref ref,
  CashMovementFilter filter,
) async {
  final repo = ref.watch(cashSessionRepositoryProvider);
  return repo.getAllMovements(
    startDate: filter.startDate,
    endDate: filter.endDate,
    userId: filter.userId,
  );
}

// Detail Provider (Composite)
class CashSessionDetail {
  final CashSession session;
  final List<CashMovement> movements;
  final List<SalePayment> payments;

  CashSessionDetail({
    required this.session,
    required this.movements,
    required this.payments,
  });

  // 1. Cash In (Tendered) - Sum of all cash payments
  int get totalCashTendered => payments
      .where((p) => p.paymentMethod == 'Efectivo')
      .fold(0, (sum, p) => sum + p.amountCents);

  // 2. Change Given - Sum of 'Cambio' movements
  int get totalChangeGiven => movements
      .where((m) => m.reason == 'Cambio')
      .fold(0, (sum, m) => sum + m.amountCents.abs());

  // 3. Cancellations/Returns - Sum of 'return' movements (or reason based)
  int get totalCancellations => movements
      .where(
        (m) =>
            m.movementType == 'return' ||
            m.reason == 'Cancelación' ||
            m.reason == 'Devolución',
      )
      .fold(0, (sum, m) => sum + m.amountCents.abs());

  // 4. True Manual Movements - Everything else
  int get totalRealManualMovements => movements
      .where(
        (m) =>
            m.reason != 'Cambio' &&
            m.movementType != 'return' &&
            m.reason != 'Cancelación' &&
            m.reason != 'Devolución',
      )
      .fold(0, (sum, m) {
        final isEntry = m.movementType == 'entry';
        return isEntry ? sum + m.amountCents : sum - m.amountCents;
      });

  // 5. Sales Total (Revenue) - Sum of payments linked to valid sales?
  // User wants "Ventas Totales: Valor real de los productos".
  int get totalGlobalSales => payments.fold(0, (sum, p) => sum + p.amountCents);

  int get totalNetSales =>
      totalCashTendered - totalChangeGiven - totalCancellations;

  int get expectedBalance {
    if (session.status == 'closed') {
      return session.expectedBalanceCents ?? 0;
    }
    // Formula: Initial + Tendered - Change - Cancellations + Manual
    return session.openingBalanceCents +
        totalCashTendered -
        totalChangeGiven -
        totalCancellations +
        totalRealManualMovements;
  }
}

@riverpod
Future<CashSessionDetail> cashSessionDetail(
  Ref ref,
  CashSession session,
) async {
  final repo = ref.watch(cashSessionRepositoryProvider);

  // Fetch in parallel
  final results = await Future.wait([
    repo.getSessionMovements(session.id!),
    repo.getAllSessionPayments(session.id!),
  ]);

  return CashSessionDetail(
    session: session,
    movements: results[0] as List<CashMovement>,
    payments: results[1] as List<SalePayment>,
  );
}
