
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/repositories/transaction_repository_impl.dart';
import 'package:myapp/domain/entities/transaction.dart';
import 'package:myapp/domain/repositories/transaction_repository.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TransactionRepositoryImpl(dbHelper);
});

final transactionProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repo);
});

class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _repository.getTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _repository.addTransaction(transaction);
      await fetchTransactions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final todaysRevenueProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return await repo.getTodaysRevenue();
});

final todaysMovementsProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return await repo.getTodaysMovements();
});
