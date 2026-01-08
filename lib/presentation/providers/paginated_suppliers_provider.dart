import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paginated_suppliers_provider.g.dart';

const int kSupplierPageSize = 20;

@riverpod
class SupplierSearchQuery extends _$SupplierSearchQuery {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }
}

@riverpod
class SupplierShowInactive extends _$SupplierShowInactive {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }
}

@riverpod
Future<int> paginatedSuppliersCount(Ref ref) async {
  final query = ref.watch(supplierSearchQueryProvider);
  final showInactive = ref.watch(supplierShowInactiveProvider);
  final repository = ref.watch(supplierRepositoryProvider);

  // Listen for database updates
  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any((u) => u.table == 'suppliers')) {
        ref.invalidateSelf();
      }
    });
  });

  return await repository.countSuppliers(
    query: query,
    showInactive: showInactive,
  );
}

@riverpod
Future<List<Supplier>> paginatedSuppliersPage(
  Ref ref, {
  required int pageIndex,
}) async {
  // Keep the provider alive to cache visited pages
  ref.keepAlive();

  final query = ref.watch(supplierSearchQueryProvider);
  final showInactive = ref.watch(supplierShowInactiveProvider);
  final repository = ref.watch(supplierRepositoryProvider);

  // Listen for database updates
  ref.listen(tableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any((u) => u.table == 'suppliers')) {
        ref.invalidateSelf();
      }
    });
  });

  final offset = pageIndex * kSupplierPageSize;

  return await repository.getAllSuppliers(
    query: query,
    limit: kSupplierPageSize,
    offset: offset,
    showInactive: showInactive,
  );
}
