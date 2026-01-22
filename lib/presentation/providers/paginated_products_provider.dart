import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/product_filters.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

part 'paginated_products_provider.g.dart';

const int kProductPageSize = 20;

@Riverpod(keepAlive: true)
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

  return result.fold((failure) => throw failure.message, (products) async {
    // If Inventory Management is enabled, we MUST show the Real Stock (Lots),
    // not the cached 'stock' column which might be desynchronized.
    final settingsAsync = ref.watch(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;

    if (useInventory && products.isNotEmpty) {
      final lotRepository = ref.watch(inventoryLotRepositoryProvider);
      const int warehouseId = 1; // TODO: Dynamic Warehouse

      // Optimize: Parallel fetch
      final updatedProducts = await Future.wait(
        products.map((product) async {
          try {
            // Fetch ALL lots for this product (aggregated variants)
            final lots = await lotRepository.getAvailableLots(
              product.id!,
              warehouseId,
            );

            // Calculate Total Stock
            final realTotalStock = lots.fold(
              0.0,
              (sum, lot) => sum + lot.quantity,
            );

            // Update Variants Stock
            // This ensures the Variant Management screen also shows correct real stock
            final updatedVariants = product.variants?.map((v) {
              final variantStock = lots
                  .where((l) => l.variantId == v.id)
                  .fold(0.0, (sum, l) => sum + l.quantity);
              return v.copyWith(stock: variantStock);
            }).toList();

            return product.copyWith(
              stock: realTotalStock.toInt(),
              variants: updatedVariants,
            );
          } catch (e) {
            return product;
          }
        }),
      );
      return updatedProducts;
    }

    return products;
  });
}
