import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_item_model.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_view.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_quantity_dialog.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_search_bar.dart';
import 'package:posventa/presentation/widgets/pos/sale/charge_bottom_bar.dart';
import 'package:posventa/presentation/mixins/search_debounce_mixin.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/weight_input_dialog.dart';

class ProductGridSection extends ConsumerStatefulWidget {
  final bool isMobile;

  const ProductGridSection({super.key, required this.isMobile});

  @override
  ConsumerState<ProductGridSection> createState() => _ProductGridSectionState();
}

class _ProductGridSectionState extends ConsumerState<ProductGridSection>
    with SearchDebounceMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openScanner() async {
    final barcode = await context.push<String>('/scanner');
    if (barcode != null && mounted) {
      _handleScannedBarcode(context, barcode);
    }
  }

  void _handleScannedBarcode(
    BuildContext scannerContext,
    String barcode,
  ) async {
    // Buscar producto por código de barras
    final productsAsync = ref.read(productListProvider);

    productsAsync.whenData((products) async {
      // Find product by its barcode OR by one of its variants' barcode
      Product? product;
      ProductVariant? matchedVariant;

      for (final p in products) {
        if (p.barcode == barcode) {
          product = p;
          break;
        }
        if (p.variants != null) {
          final variant = p.variants!
              .where((v) => v.barcode == barcode && v.isForSale)
              .firstOrNull;
          if (variant != null) {
            product = p;
            matchedVariant = variant;
            break;
          }
        }
      }

      if (product != null) {
        // Validation for weight-based products
        double quantity = 1.0;
        if (product.isSoldByWeight ||
            (matchedVariant?.isSoldByWeight ?? false)) {
          if (!scannerContext.mounted) return;
          final result = await showDialog<double>(
            context: scannerContext,
            builder: (context) =>
                WeightInputDialog(product: product!, variant: matchedVariant),
          );
          if (result == null) return; // Cancelled
          quantity = result;
        }

        // Agregar al carrito con validación de stock
        final error = await ref
            .read(pOSProvider.notifier)
            .addToCart(product, variant: matchedVariant, quantity: quantity);

        if (error != null && scannerContext.mounted) {
          // Mostrar error de stock
          _showStockError(scannerContext, error);
        } else if (scannerContext.mounted) {
          // Success feedback handled silently or via UI update
        }
      } else if (scannerContext.mounted) {
        // Producto no encontrado
        _showStockError(scannerContext, 'Producto no encontrado: $barcode');
      }
    });
  }

  List<ProductGridItem> _buildGridItems(List<Product> products) {
    final List<ProductGridItem> gridItems = [];
    for (final product in products) {
      // Omitir productos inactivos en el POS
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

  Future<void> _onProductTap(ProductGridItem item) async {
    // Check if product is sold by weight
    double quantity = 1.0;
    if (item.product.isSoldByWeight ||
        (item.variant?.isSoldByWeight ?? false)) {
      final result = await showDialog<double>(
        context: context,
        builder: (context) =>
            WeightInputDialog(product: item.product, variant: item.variant),
      );
      if (result == null) return; // Cancelled
      quantity = result;
    }

    // Add directly to cart without dialog (unless weight input was needed)
    final error = await ref
        .read(pOSProvider.notifier)
        .addToCart(item.product, variant: item.variant, quantity: quantity);

    if (error != null && mounted) {
      _showStockError(context, error);
    } else if (mounted) {
      // Success feedback handled silently or via UI update
    }
  }

  Future<void> _onProductLongPress(ProductGridItem item) async {
    showDialog(
      context: context,
      builder: (context) => ProductQuantityDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final cart = ref.watch(pOSProvider.select((s) => s.cart));

    // Efficiently map cart quantities
    final Map<int, Map<int?, double>> cartQuantities = {};
    for (final item in cart) {
      cartQuantities.putIfAbsent(item.productId, () => {});
      cartQuantities[item.productId]![item.variantId] =
          (cartQuantities[item.productId]![item.variantId] ?? 0) +
          item.quantity;
    }

    return Column(
      children: [
        // Search Bar with Scanner
        ProductSearchBar(
          controller: _searchController,
          onChanged: (value) {
            debounceSearch(() {
              ref.read(productListProvider.notifier).searchProducts(value);
              setState(() {});
            });
          },
          onClear: () {
            _searchController.clear();
            ref.read(productListProvider.notifier).searchProducts('');
            setState(() {});
          },
          onScan: _openScanner,
        ),
        // Product Grid
        Expanded(
          child: productsAsync.when(
            data: (products) {
              final gridItems = _buildGridItems(products);
              return ProductGridView(
                items: gridItems,
                isMobile: widget.isMobile,
                onItemTap: _onProductTap,
                onItemLongPress: _onProductLongPress,
                cartQuantities: cartQuantities,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: $err'),
                ],
              ),
            ),
          ),
        ),
        // Charge Bottom Bar (Only for Mobile)
        if (widget.isMobile) const ConnectedChargeBottomBar(),
      ],
    );
  }

  void _showStockError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 18,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
