import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/domain/entities/transaction.dart';
import 'package:posventa/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepositoryImpl(this._databaseHelper);

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final db = await _databaseHelper.database;
    await db.insert('transactions', transaction.toMap());
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('transactions', orderBy: 'timestamp DESC');
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  @override
  Future<double> getTodaysRevenue() async {
    final db = await _databaseHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();

    // Query sales table instead of transactions
    final result = await db.rawQuery(
      'SELECT SUM(total_cents) as total FROM sales WHERE status != ? AND sale_date BETWEEN ? AND ?',
      ['cancelled', startOfDay, endOfDay],
    );

    final totalSalesCents = (result.first['total'] as int?) ?? 0;

    // Subtract manual returns (cash movements of type 'return')
    final returnsResult = await db.rawQuery(
      'SELECT SUM(amount_cents) as total FROM cash_movements WHERE movement_type = ? AND movement_date BETWEEN ? AND ?',
      ['return', startOfDay, endOfDay],
    );

    final totalReturnsCents = (returnsResult.first['total'] as int?) ?? 0;

    return (totalSalesCents - totalReturnsCents) / 100.0;
  }

  @override
  Future<int> getTodaysMovements() async {
    final db = await _databaseHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();

    // Query sales table count
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sales WHERE status != ? AND sale_date BETWEEN ? AND ?',
      ['cancelled', startOfDay, endOfDay],
    );

    final count = result.first['count'];
    return (count as int?) ?? 0;
  }
}
