import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/entities/transaction.dart';
import 'package:posventa/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final drift_db.AppDatabase db;

  TransactionRepositoryImpl(this.db);

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await db
        .into(db.transactions)
        .insert(
          drift_db.TransactionsCompanion.insert(
            userId: Value(transaction.userId),
            amount: transaction.amount,
            type: transaction.type.name,
            description: Value(transaction.description),
            date: transaction.timestamp,
          ),
        );
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final rows = await (db.select(
      db.transactions,
    )..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

    return rows
        .map(
          (row) => Transaction(
            id: row.id,
            userId: row.userId!,
            amount: row.amount,
            type: TransactionType.values.firstWhere((e) => e.name == row.type),
            description: row.description ?? '',
            timestamp: row.date,
          ),
        )
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByUserId(int userId) async {
    final rows =
        await (db.select(db.transactions)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.desc(t.date)]))
            .get();

    return rows
        .map(
          (row) => Transaction(
            id: row.id,
            userId: row.userId!,
            amount: row.amount,
            type: TransactionType.values.firstWhere((e) => e.name == row.type),
            description: row.description ?? '',
            timestamp: row.date,
          ),
        )
        .toList();
  }

  @override
  Future<double> getTodaysRevenue() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final salesQuery = db.selectOnly(db.sales)
      ..addColumns([db.sales.totalCents.sum()])
      ..where(
        db.sales.saleDate.isBetweenValues(startOfDay, endOfDay) &
            db.sales.status.equals('completed'),
      );

    final salesResult = await salesQuery.getSingle();
    final totalSalesCents = salesResult.read(db.sales.totalCents.sum()) ?? 0;

    final returnsQuery = db.selectOnly(db.saleReturns)
      ..addColumns([db.saleReturns.totalCents.sum()])
      ..where(
        db.saleReturns.returnDate.isBetweenValues(startOfDay, endOfDay) &
            db.saleReturns.status.equals('completed'),
      );

    final returnsResult = await returnsQuery.getSingle();
    final totalReturnsCents =
        returnsResult.read(db.saleReturns.totalCents.sum()) ?? 0;

    return (totalSalesCents - totalReturnsCents) / 100.0;
  }

  @override
  Future<int> getTodaysMovements() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final countQuery = db.selectOnly(db.sales)
      ..addColumns([db.sales.id.count()])
      ..where(
        db.sales.saleDate.isBetweenValues(startOfDay, endOfDay) &
            db.sales.status.isNotValue('cancelled'),
      );

    final result = await countQuery.getSingle();
    return result.read(db.sales.id.count()) ?? 0;
  }
}
