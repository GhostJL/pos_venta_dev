
import 'package:myapp/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(Transaction transaction);
  Future<List<Transaction>> getTransactions();
  Future<List<Transaction>> getTransactionsByUserId(int userId);
  Future<double> getTodaysRevenue();
  Future<int> getTodaysMovements();
}
