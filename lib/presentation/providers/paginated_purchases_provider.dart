import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/purchase_filter_chip_provider.dart';

part 'paginated_purchases_provider.g.dart';

const int kPurchasePageSize = 20;

@riverpod
class PurchaseSearchQuery extends _$PurchaseSearchQuery {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }
}

@riverpod
Future<int> paginatedPurchasesCount(Ref ref) async {
  final query = ref.watch(purchaseSearchQueryProvider);
  final status = ref.watch(purchaseFilterProvider);
  final repository = ref.watch(purchaseRepositoryProvider);

  // Listen for database updates
  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any((u) => u.table == 'purchases')) {
        ref.invalidateSelf();
      }
    });
  });

  return await repository.countPurchases(query: query, status: status);
}

@riverpod
Future<List<Purchase>> paginatedPurchasesPage(
  Ref ref, {
  required int pageIndex,
}) async {
  // Keep the provider alive to cache visited pages
  ref.keepAlive();

  final query = ref.watch(purchaseSearchQueryProvider);
  final status = ref.watch(purchaseFilterProvider);
  final repository = ref.watch(purchaseRepositoryProvider);

  // Listen for database updates
  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any((u) => u.table == 'purchases')) {
        ref.invalidateSelf();
      }
    });
  });

  final offset = pageIndex * kPurchasePageSize;

  return await repository.getPurchases(
    query: query,
    status: status,
    limit: kPurchasePageSize,
    offset: offset,
  );
}
