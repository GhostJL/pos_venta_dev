import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';
import 'package:posventa/data/repositories/sale_repository_impl.dart';
import 'package:posventa/domain/use_cases/sale/create_sale_use_case.dart';
import 'package:posventa/domain/use_cases/sale/get_sales_use_case.dart';
import 'package:posventa/domain/use_cases/sale/get_sale_by_id_use_case.dart';
import 'package:posventa/domain/use_cases/sale/generate_next_sale_number_use_case.dart';
import 'package:posventa/domain/use_cases/sale/cancel_sale_use_case.dart';
import 'package:posventa/domain/repositories/sale_return_repository.dart';
import 'package:posventa/data/repositories/sale_return_repository_impl.dart';
import 'package:posventa/domain/use_cases/sale_return/create_sale_return_use_case.dart';
import 'package:posventa/domain/use_cases/sale_return/get_sale_returns_use_case.dart';
import 'package:posventa/domain/use_cases/sale_return/get_sale_return_by_id_use_case.dart';
import 'package:posventa/domain/use_cases/sale_return/generate_next_return_number_use_case.dart';
import 'package:posventa/domain/use_cases/sale_return/validate_return_eligibility_use_case.dart';
import 'package:posventa/domain/use_cases/sale_return/get_returns_stats_use_case.dart';
import 'package:posventa/domain/repositories/transaction_repository.dart';
import 'package:posventa/data/repositories/transaction_repository_impl.dart';
import 'package:posventa/domain/repositories/cash_session_repository.dart';
import 'package:posventa/data/repositories/cash_session_repository_impl.dart';
import 'package:posventa/domain/use_cases/cash_movement/get_current_session.dart';
import 'package:posventa/domain/use_cases/cash_movement/create_cash_movement.dart';
import 'package:posventa/domain/repositories/cash_movement_repository.dart';
import 'package:posventa/data/repositories/cash_movement_repository_impl.dart';
import 'package:posventa/domain/use_cases/cash_session/open_cash_session_use_case.dart';
import 'package:posventa/domain/use_cases/cash_session/close_cash_session_use_case.dart';
import 'package:posventa/domain/use_cases/cash_session/get_current_cash_session_use_case.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:posventa/presentation/providers/di/inventory_di.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

part 'sale_di.g.dart';

// --- Transaction Providers ---

@riverpod
TransactionRepository transactionRepository(ref) =>
    TransactionRepositoryImpl(ref.watch(appDatabaseProvider));

// --- Sale Providers ---

@riverpod
SaleRepository saleRepository(ref) =>
    SaleRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
Future<CreateSaleUseCase> createSaleUseCase(ref) async => CreateSaleUseCase(
  ref.watch(saleRepositoryProvider),
  ref.watch(inventoryLotRepositoryProvider),
  await ref.watch(settingsRepositoryProvider.future),
);

@riverpod
GetSalesUseCase getSalesUseCase(ref) =>
    GetSalesUseCase(ref.watch(saleRepositoryProvider));

@riverpod
GetSaleByIdUseCase getSaleByIdUseCase(ref) =>
    GetSaleByIdUseCase(ref.watch(saleRepositoryProvider));

@riverpod
GenerateNextSaleNumberUseCase generateNextSaleNumberUseCase(ref) =>
    GenerateNextSaleNumberUseCase(ref.watch(saleRepositoryProvider));

@riverpod
Future<CancelSaleUseCase> cancelSaleUseCase(ref) async => CancelSaleUseCase(
  ref.watch(saleRepositoryProvider),
  ref.watch(createCashMovementUseCaseProvider),
  ref.watch(getCurrentSessionProvider),
  await ref.watch(settingsRepositoryProvider.future),
);

final salesListStreamProvider = StreamProvider.autoDispose
    .family<List<Sale>, ({DateTime? startDate, DateTime? endDate})>((
      ref,
      args,
    ) {
      final link = ref.keepAlive(); // Keep alive if desired

      return ref
          .watch(getSalesUseCaseProvider)
          .stream(startDate: args.startDate, endDate: args.endDate);
    });

final allSaleReturnsProvider = StreamProvider.autoDispose<List<SaleReturn>>((
  ref,
) {
  ref.keepAlive();

  final repository = ref.watch(saleReturnRepositoryProvider);

  return repository.getSaleReturnsStream();
});

// Stream providers for real-time updates
final saleDetailStreamProvider = StreamProvider.family<Sale?, int>((
  ref,
  saleId,
) {
  return ref.watch(getSaleByIdUseCaseProvider).stream(saleId);
});

// --- Dashboard Metrics Providers ---

@riverpod
Future<double> todaysRevenue(Ref ref) {
  return ref.watch(transactionRepositoryProvider).getTodaysRevenue();
}

@riverpod
Future<int> todaysTransactions(Ref ref) {
  return ref.watch(transactionRepositoryProvider).getTodaysMovements();
}

// --- Cash Session Providers ---

@riverpod
CashSessionRepository cashSessionRepository(ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  if (user == null) {
    throw Exception('User not authenticated');
  }
  return CashSessionRepositoryImpl(ref.watch(appDatabaseProvider), user.id!);
}

@riverpod
GetCurrentSession getCurrentSession(ref) =>
    GetCurrentSession(ref.watch(cashSessionRepositoryProvider));

@riverpod
GetCurrentCashSessionUseCase getCurrentCashSessionUseCase(ref) =>
    GetCurrentCashSessionUseCase(ref.watch(cashSessionRepositoryProvider));

@riverpod
OpenCashSessionUseCase openCashSessionUseCase(ref) =>
    OpenCashSessionUseCase(ref.watch(cashSessionRepositoryProvider));

@riverpod
CloseCashSessionUseCase closeCashSessionUseCase(ref) =>
    CloseCashSessionUseCase(ref.watch(cashSessionRepositoryProvider));

@riverpod
Future<CashSession?> currentCashSession(ref) async {
  return await ref.watch(getCurrentCashSessionUseCaseProvider).call();
}

// --- Sale Return Providers ---

@riverpod
SaleReturnRepository saleReturnRepository(ref) =>
    SaleReturnRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
CreateSaleReturnUseCase createSaleReturnUseCase(ref) =>
    CreateSaleReturnUseCase(ref.watch(saleReturnRepositoryProvider));

@riverpod
GetSaleReturnsUseCase getSaleReturnsUseCase(ref) =>
    GetSaleReturnsUseCase(ref.watch(saleReturnRepositoryProvider));

@riverpod
GetSaleReturnByIdUseCase getSaleReturnByIdUseCase(ref) =>
    GetSaleReturnByIdUseCase(ref.watch(saleReturnRepositoryProvider));

@riverpod
GenerateNextReturnNumberUseCase generateNextReturnNumberUseCase(ref) =>
    GenerateNextReturnNumberUseCase(ref.watch(saleReturnRepositoryProvider));

@riverpod
ValidateReturnEligibilityUseCase validateReturnEligibilityUseCase(ref) =>
    ValidateReturnEligibilityUseCase(ref.watch(saleReturnRepositoryProvider));

@riverpod
GetReturnsStatsUseCase getReturnsStatsUseCase(ref) =>
    GetReturnsStatsUseCase(ref.watch(saleReturnRepositoryProvider));

// --- Cash Movement Providers ---

@riverpod
CashMovementRepository cashMovementRepository(Ref ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  if (user == null) {
    throw Exception('User not authenticated');
  }
  return CashMovementRepositoryImpl(ref.watch(appDatabaseProvider), user.id!);
}

@riverpod
CreateCashMovement createCashMovementUseCase(Ref ref) =>
    CreateCashMovement(ref.watch(cashMovementRepositoryProvider));
