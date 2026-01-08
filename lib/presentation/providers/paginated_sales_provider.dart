import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/providers.dart';

part 'paginated_sales_provider.g.dart';

const int kSalePageSize = 20;

@riverpod
class SaleDateRange extends _$SaleDateRange {
  @override
  ({DateTime? start, DateTime? end}) build() {
    return (start: null, end: null);
  }

  void setRange(DateTime? start, DateTime? end) {
    state = (start: start, end: end);
  }
}

@riverpod
Future<int> paginatedSalesCount(Ref ref) async {
  final dateRange = ref.watch(saleDateRangeProvider);
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
    startDate: dateRange.start,
    endDate: dateRange.end,
  );
}

@riverpod
Future<List<Sale>> paginatedSalesPage(Ref ref, {required int pageIndex}) async {
  // Keep the provider alive
  ref.keepAlive();

  final dateRange = ref.watch(saleDateRangeProvider);
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
    startDate: dateRange.start,
    endDate: dateRange.end,
    limit: kSalePageSize,
    offset: offset,
  );
}
