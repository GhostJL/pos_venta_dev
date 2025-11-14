import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/repositories/cash_movement_repository_impl.dart';
import 'package:myapp/domain/entities/cash_movement.dart';
import 'package:myapp/domain/use_cases/create_cash_movement.dart';
import 'package:myapp/domain/use_cases/get_movements_by_session.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';

final cashMovementRepositoryProvider = Provider((ref) {
  final dbHelper = DatabaseHelper();
  final user = ref.watch(authStateProvider);
  // Make sure to handle the case where user is null
  final userId = user?.id ?? -1; // Or some other default/error value
  return CashMovementRepositoryImpl(dbHelper, userId);
});

final createCashMovementProvider = Provider((ref) {
  final repository = ref.watch(cashMovementRepositoryProvider);
  return CreateCashMovement(repository);
});

final getMovementsBySessionProvider = Provider((ref) {
  final repository = ref.watch(cashMovementRepositoryProvider);
  return GetMovementsBySession(repository);
});

final cashMovementProvider =
    StateNotifierProvider<CashMovementNotifier, AsyncValue<List<CashMovement>>>(
      (ref) {
        return CashMovementNotifier(ref);
      },
    );

class CashMovementNotifier
    extends StateNotifier<AsyncValue<List<CashMovement>>> {
  final Ref _ref;

  CashMovementNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> createMovement(
    int cashSessionId,
    String movementType,
    int amountCents,
    String reason, {
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      final createCashMovement = _ref.read(createCashMovementProvider);
      await createCashMovement(
        cashSessionId,
        movementType,
        amountCents,
        reason,
        description: description,
      );
      // After creating a movement, refresh the list of movements for the session
      final getMovementsBySession = _ref.read(getMovementsBySessionProvider);
      final movements = await getMovementsBySession(cashSessionId);
      state = AsyncValue.data(movements);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow; // Re-throw the exception
    }
  }

  Future<void> getMovementsBySession(int sessionId) async {
    state = const AsyncValue.loading();
    try {
      final getMovementsBySession = _ref.read(getMovementsBySessionProvider);
      final movements = await getMovementsBySession(sessionId);
      state = AsyncValue.data(movements);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
