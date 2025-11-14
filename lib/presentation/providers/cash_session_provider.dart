
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/repositories/cash_session_repository_impl.dart';
import 'package:myapp/domain/entities/cash_session.dart';
import 'package:myapp/domain/use_cases/close_session.dart';
import 'package:myapp/domain/use_cases/get_current_session.dart';
import 'package:myapp/domain/use_cases/open_session.dart';

final cashSessionRepositoryProvider = Provider((ref) {
  final dbHelper = DatabaseHelper();
  return CashSessionRepositoryImpl(dbHelper);
});

final openSessionProvider = Provider((ref) {
  final repository = ref.watch(cashSessionRepositoryProvider);
  return OpenSession(repository);
});

final closeSessionProvider = Provider((ref) {
  final repository = ref.watch(cashSessionRepositoryProvider);
  return CloseSession(repository);
});

final getCurrentSessionProvider = Provider((ref) {
  final repository = ref.watch(cashSessionRepositoryProvider);
  return GetCurrentSession(repository);
});

final cashSessionProvider = StateNotifierProvider<CashSessionNotifier, AsyncValue<CashSession?>>((ref) {
  return CashSessionNotifier(ref);
});

class CashSessionNotifier extends StateNotifier<AsyncValue<CashSession?>> {
  final Ref _ref;

  CashSessionNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> openSession(int warehouseId, int userId, int openingBalanceCents) async {
    state = const AsyncValue.loading();
    try {
      final openSession = _ref.read(openSessionProvider);
      final session = await openSession(warehouseId, userId, openingBalanceCents);
      state = AsyncValue.data(session);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> closeSession(int sessionId, int closingBalanceCents) async {
    state = const AsyncValue.loading();
    try {
      final closeSession = _ref.read(closeSessionProvider);
      final session = await closeSession(sessionId, closingBalanceCents);
      state = AsyncValue.data(session);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> getCurrentSession(int userId) async {
    state = const AsyncValue.loading();
    try {
      final getCurrentSession = _ref.read(getCurrentSessionProvider);
      final session = await getCurrentSession(userId);
      state = AsyncValue.data(session);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
