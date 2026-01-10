import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/providers.dart';

part 'paginated_sales_provider.g.dart';

const int kSalePageSize = 20;

@riverpod
class SaleFilter extends _$SaleFilter {
  @override
  ({DateTime? start, DateTime? end, int? cashierId}) build() {
    return (start: null, end: null, cashierId: null);
  }

  void setRange(DateTime? start, DateTime? end) {
    state = (start: start, end: end, cashierId: state.cashierId);
  }

  void setCashierId(int? cashierId) {
    state = (start: state.start, end: state.end, cashierId: cashierId);
  }
}

@riverpod
Future<int> paginatedSalesCount(Ref ref) async {
  final filter = ref.watch(saleFilterProvider);
  final repository = ref.watch(saleRepositoryProvider);

  // Listen for database updates
  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any((u) => u.table == 'sales')) {
        ref.invalidateSelf();
      }
    });
  });

  return await repository.countSales(
    startDate: filter.start,
    endDate: filter.end,
    cashierId: filter.cashierId,
  );
}

@riverpod
Future<List<Sale>> paginatedSalesPage(Ref ref, {required int pageIndex}) async {
  // Keep the provider alive
  ref.keepAlive();

  final filter = ref.watch(saleFilterProvider);
  final repository = ref.watch(saleRepositoryProvider);

  // Listen for database updates
  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any((u) => u.table == 'sales')) {
        ref.invalidateSelf();
      }
    });
  });

  final offset = pageIndex * kSalePageSize;

  return await repository.getSales(
    startDate: filter.start,
    endDate: filter.end,
    cashierId: filter.cashierId,
    limit: kSalePageSize,
    offset: offset,
  );
}
