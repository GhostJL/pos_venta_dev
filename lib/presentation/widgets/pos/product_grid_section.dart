import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_item_model.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_view.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_search_bar.dart';

class ProductGridSection extends ConsumerStatefulWidget {
  final bool isMobile;

  const ProductGridSection({super.key, required this.isMobile});

  @override
  ConsumerState<ProductGridSection> createState() => _ProductGridSectionState();
}

class _ProductGridSectionState extends ConsumerState<ProductGridSection> {
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
        // Agregar al carrito con validación de stock
        final error = await ref
            .read(pOSProvider.notifier)
            .addToCart(product, variant: matchedVariant);

        if (error != null && scannerContext.mounted) {
          // Mostrar error de stock
          _showStockError(scannerContext, error);
        } else if (scannerContext.mounted) {
          // Mostrar feedback de éxito
          _showProductAdded(
            scannerContext,
            matchedVariant != null
                ? '${product.name} (${matchedVariant.description})'
                : product.name,
          );
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
    // Add directly to cart without dialog
    final error = await ref
        .read(pOSProvider.notifier)
        .addToCart(item.product, variant: item.variant);

    if (error != null && mounted) {
      _showStockError(context, error);
    } else if (mounted) {
      _showProductAdded(context, item.displayName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Column(
      children: [
        // Search Bar with Scanner
        ProductSearchBar(
          controller: _searchController,
          onChanged: (value) {
            ref.read(productListProvider.notifier).searchProducts(value);
            setState(() {});
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
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $err'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showProductAdded(BuildContext context, String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onSurface,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              productName,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 16,
          right: 16,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showStockError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Theme.of(context).colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 16,
          right: 16,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
