import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_item_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_grid_provider.g.dart';

@riverpod
Future<List<ProductGridItem>> posGridItems(Ref ref) async {
  // Watch the product list. This provider rebuilds when search query changes.
  final products = await ref.watch(productListProvider.future);

  // Perform the heavy mapping in this provider, so it's cached.
  // It will NOT re-run when the cart changes.
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
