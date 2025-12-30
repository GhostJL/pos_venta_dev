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
import 'package:posventa/presentation/widgets/common/misc/scanner_arguments.dart';

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
    await context.push<String>(
      '/scanner',
      extra: ScannerArguments(
        onScan: (context, barcode) async {
          return await _handleScannedBarcode(context, barcode);
        },
      ),
    );
  }

  Future<(bool, String)> _handleScannedBarcode(
    BuildContext scannerContext,
    String barcode,
  ) async {
    // Buscar producto por código de barras
    final productsAsync = ref.read(productListProvider);

    return productsAsync.when(
      data: (state) async {
        final products = state.products;
        // Find product by its barcode OR by one of its variants' barcode
        Product? product;
        ProductVariant? matchedVariant;

        for (final p in products) {
          // Check variants first for more specific match
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

          // Then check parent product
          if (p.barcode == barcode) {
            product = p;
            break;
          }
        }

        if (product != null) {
          // Validation for weight-based products
          double quantity = 1.0;
          if (product.isSoldByWeight ||
              (matchedVariant?.isSoldByWeight ?? false)) {
            if (!scannerContext.mounted) return (false, 'Error de contexto');
            final result = await showDialog<double>(
              context: scannerContext,
              builder: (context) =>
                  WeightInputDialog(product: product!, variant: matchedVariant),
            );
            if (result == null) return (false, 'Cancelado'); // Cancelled
            quantity = result;
          }

          // Agregar al carrito con validación de stock
          final error = await ref
              .read(pOSProvider.notifier)
              .addToCart(product, variant: matchedVariant, quantity: quantity);

          if (error != null) {
            return (false, error);
          }
          return (true, 'Agregado: ${product.name}'); // Added successfully
        } else {
          return (false, 'No encontrado: $barcode'); // Not found
        }
      },
      loading: () => (false, 'Cargando...'),
      error: (_, __) => (false, 'Error al buscar producto'),
    );
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
            data: (state) {
              final products = state.products;
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
