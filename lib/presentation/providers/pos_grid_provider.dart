import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_item_model.dart';
import 'package:posventa/presentation/providers/di/product_di.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_grid_provider.g.dart';

@riverpod
Future<List<ProductGridItem>> posGridItems(Ref ref) async {
  // Watch repositories/usecases
  final query = ref.watch(productSearchQueryProvider);
  final searchUseCase = ref.watch(searchProductsProvider);
  final saleRepository = ref.watch(saleRepositoryProvider);

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

  List<ProductGridItem> gridItems = [];
  final Set<int> addedProductIds = {};

  if (query.isEmpty) {
    // Strategy:
    // 1. Fetch top selling products of the day
    // 2. Fetch those specific products (filtered by stock > 0)
    // 3. If less than 40, fetch remaining from standard list (filtered by stock > 0)

    try {
      final topIds = await saleRepository.getTopSellingProductIds(
        DateTime.now(),
      );

      if (topIds.isNotEmpty) {
        final topProductsResult = await searchUseCase.call(
          '',
          ids: topIds,
          onlyWithStock: true,
          limit: topIds.length,
        );

        topProductsResult.fold(
          (failure) =>
              null, // Ignore failure for optimization, fallback to list
          (products) {
            for (final product in products) {
              if (!product.isActive) continue;
              // Process variants
              final sellableVariants =
                  product.variants?.where((v) => v.isForSale).toList() ?? [];
              if (sellableVariants.isNotEmpty) {
                for (final variant in sellableVariants) {
                  if ((variant.stock ?? 0) > 0) {
                    gridItems.add(
                      ProductGridItem(product: product, variant: variant),
                    );
                  }
                }
              } else {
                if ((product.stock ?? 0) > 0) {
                  gridItems.add(ProductGridItem(product: product));
                }
              }
              if (product.id != null) {
                addedProductIds.add(product.id!);
              }
            }
          },
        );
      }

      // If we don't have enough items (e.g. 40), fetch more
      if (gridItems.length < 40) {
        final remainingLimit = 40 - gridItems.length;

        // We can't easily "exclude" IDs in one go without 'excludeIds' param which we added? No, we added 'ids'.
        // So we just fetch standard list (limit 40 or 50) and filter in Dart, or just fetch and append if not present.
        // Efficient way: Fetch 50, filter duplicates.

        final standardResult = await searchUseCase.call(
          '',
          sortOrder: 'stock_desc', // Or 'id_desc'
          onlyWithStock: true,
          limit: 50,
        );

        standardResult.fold((failure) => throw Exception(failure.message), (
          products,
        ) {
          for (final product in products) {
            if (addedProductIds.contains(product.id)) continue;
            if (!product.isActive) continue;

            final sellableVariants =
                product.variants?.where((v) => v.isForSale).toList() ?? [];
            if (sellableVariants.isNotEmpty) {
              for (final variant in sellableVariants) {
                if ((variant.stock ?? 0) > 0) {
                  gridItems.add(
                    ProductGridItem(product: product, variant: variant),
                  );
                }
              }
            } else {
              if ((product.stock ?? 0) > 0) {
                gridItems.add(ProductGridItem(product: product));
              }
            }
            if (product.id != null) {
              addedProductIds.add(product.id!);
            }
            if (gridItems.length >= 40) break;
          }
        });
      }
    } catch (e) {
      // Fallback
    }
  } else {
    // Search query active
    final result = await searchUseCase.call(
      query,
      sortOrder: 'stock_desc',
      onlyWithStock: true, // Requested optimization
      limit: 50,
    );

    result.fold((failure) => throw Exception(failure.message), (data) {
      for (final product in data) {
        if (!product.isActive) continue;
        final sellableVariants =
            product.variants?.where((v) => v.isForSale).toList() ?? [];
        if (sellableVariants.isNotEmpty) {
          for (final variant in sellableVariants) {
            // Should we enforce stock > 0 for search too?
            // User said "creo que es mejor solo mostrar los productos con stock disponible".
            // Implied generally.
            if ((variant.stock ?? 0) > 0) {
              gridItems.add(
                ProductGridItem(product: product, variant: variant),
              );
            }
          }
        } else {
          if ((product.stock ?? 0) > 0) {
            gridItems.add(ProductGridItem(product: product));
          }
        }
      }
    });
  }

  return gridItems;
}
