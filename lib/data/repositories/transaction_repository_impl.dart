
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/domain/entities/transaction.dart';
import 'package:myapp/domain/repositories/transaction_repository.dart';

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
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND timestamp BETWEEN ? AND ?',
      ['income', startOfDay, endOfDay],
    );

    final total = result.first['total'];
    return (total as double?) ?? 0.0;
  }

  @override
  Future<int> getTodaysMovements() async {
    final db = await _databaseHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE timestamp BETWEEN ? AND ?',
      [startOfDay, endOfDay],
    );

    final count = result.first['count'];
    return (count as int?) ?? 0;
  }
}
