import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/product_filters.dart';

part 'paginated_products_provider.g.dart';

const int kProductPageSize = 20;

@riverpod
Future<int> paginatedProductsCount(Ref ref) async {
  final query = ref.watch(productSearchQueryProvider);
  final filters = ref.watch(productFiltersProvider);
  final repository = ref.watch(productRepositoryProvider);

  // Listen for database updates (Debounced)
  ref.listen(debouncedTableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any(
        (u) =>
            u.table == 'products' ||
            u.table == 'inventory' ||
            u.table == 'product_variants',
      )) {
        ref.invalidateSelf();
      }
    });
  });

  final result = await repository.countProducts(
    query: query,
    departmentId: filters.departmentId,
    categoryId: filters.categoryId,
    brandId: filters.brandId,
    supplierId: filters.supplierId,
    showInactive: filters.showInactive,
  );
  return result.fold((failure) => throw failure.message, (count) => count);
}

@riverpod
Future<List<Product>> paginatedProductsPage(
  Ref ref, {
  required int pageIndex,
}) async {
  // Keep the provider alive to cache visited pages
  ref.keepAlive();

  final query = ref.watch(productSearchQueryProvider);
  final filters = ref.watch(productFiltersProvider);
  final repository = ref.watch(productRepositoryProvider);

  // Listen for database updates (Debounced)
  ref.listen(debouncedTableUpdateStreamProvider, (previous, next) {
    next.whenData((updates) {
      if (updates.any(
        (u) =>
            u.table == 'products' ||
            u.table == 'inventory' ||
            u.table == 'product_variants',
      )) {
        ref.invalidateSelf();
      }
    });
  });

  final offset = pageIndex * kProductPageSize;

  final result = await repository.getProducts(
    query: query,
    departmentId: filters.departmentId,
    categoryId: filters.categoryId,
    brandId: filters.brandId,
    supplierId: filters.supplierId,
    showInactive: filters.showInactive,
    sortOrder: filters.sortOrder,
    limit: kProductPageSize,
    offset: offset,
  );

  return result.fold(
    (failure) => throw failure.message,
    (products) => products,
  );
}
