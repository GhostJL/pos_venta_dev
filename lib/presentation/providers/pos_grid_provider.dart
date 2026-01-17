import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_item_model.dart';
import 'package:posventa/presentation/providers/di/product_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_grid_provider.g.dart';

@riverpod
Future<List<ProductGridItem>> posGridItems(Ref ref) async {
  // Watch search query
  final query = ref.watch(productSearchQueryProvider);
  final searchUseCase = ref.watch(searchProductsProvider);

  // Call use case directly with 'stock_desc' sorting
  // Limit to 50 if query is empty to avoid loading all products at once
  // (Though for stock sorting we fetch all in datasource, we still limit the return here)
  final result = await searchUseCase.call(
    query,
    sortOrder: 'stock_desc',
    limit: query.isEmpty ? 50 : null,
  );

  final products = result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );

  final List<ProductGridItem> gridItems = [];
  for (final product in products) {
    // Omit inactive products
    if (!product.isActive) continue;

    final sellableVariants =
        product.variants?.where((v) => v.isForSale).toList() ?? [];

    if (sellableVariants.isNotEmpty) {
      // Add each sellable variant as a separate grid item
      for (final variant in sellableVariants) {
        gridItems.add(ProductGridItem(product: product, variant: variant));
      }
    } else {
      // Add product without variant
      gridItems.add(ProductGridItem(product: product));
    }
  }
  return gridItems;
}
