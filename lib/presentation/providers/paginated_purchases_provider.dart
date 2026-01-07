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
  // Note: PurchaseFilter is not fully integrated in counting/querying in the repo yet for 'status' filtering
  // The current repo `countPurchases` only accepts `query`.
  // If we want status filtering, we need to update repo again or simpler:
  // For now, let's stick to query. If user wants status filter, we might need to update repo.
  // The plan said "PurchaseFilterProvider (or reuse existing)".
  // Existing PurchasesPage filters by status client-side AFTER loading all.
  // Ideally we should move it to DB.
  // For this task, I will stick to what I added to Repo: `query`.

  // Listen for database updates
  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((table) {
      if (table == 'purchases') {
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
    next.whenData((table) {
      if (table == 'purchases') {
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
