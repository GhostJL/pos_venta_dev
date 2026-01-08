import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paginated_customers_provider.g.dart';

const int kCustomerPageSize = 20;

@riverpod
class CustomerSearchQuery extends _$CustomerSearchQuery {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }
}

@riverpod
class CustomerShowInactive extends _$CustomerShowInactive {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }
}

@riverpod
Future<int> paginatedCustomersCount(Ref ref) async {
  final query = ref.watch(customerSearchQueryProvider);
  final showInactive = ref.watch(customerShowInactiveProvider);
  final repository = ref.watch(customerRepositoryProvider);

  // Listen for database updates
  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any((u) => u.table == 'customers')) {
        ref.invalidateSelf();
      }
    });
  });

  return await repository.countCustomers(
    query: query,
    showInactive: showInactive,
  );
}

@riverpod
Future<List<Customer>> paginatedCustomersPage(
  Ref ref, {
  required int pageIndex,
}) async {
  // Keep the provider alive to cache visited pages
  ref.keepAlive();

  final query = ref.watch(customerSearchQueryProvider);
  final showInactive = ref.watch(customerShowInactiveProvider);
  final repository = ref.watch(customerRepositoryProvider);

  // Listen for database updates
  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any((u) => u.table == 'customers')) {
        ref.invalidateSelf();
      }
    });
  });

  final offset = pageIndex * kCustomerPageSize;

  return await repository.getCustomers(
    query: query,
    limit: kCustomerPageSize,
    offset: offset,
    showInactive: showInactive,
  );
}
