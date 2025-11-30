import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/widgets/pos/product_cart_widget.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

/// Helper class to represent a product or variant as a single grid item
class ProductGridItem {
  final Product product;
  final ProductVariant? variant;

  ProductGridItem({required this.product, this.variant});

  String get displayName {
    if (variant != null) {
      return '${product.name}\n${variant!.description}';
    }
    return product.name;
  }

  int get priceCents => variant?.priceCents ?? product.salePriceCents;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductGridItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id &&
          variant?.id == other.variant?.id;

  @override
  int get hashCode => product.id.hashCode ^ (variant?.id.hashCode ?? 0);
}

class ProductGridSection extends ConsumerStatefulWidget {
  final bool isMobile;

  const ProductGridSection({super.key, required this.isMobile});

  @override
  ConsumerState<ProductGridSection> createState() => _ProductGridSectionState();
}

class _ProductGridSectionState extends ConsumerState<ProductGridSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Column(
      children: [
        // Search Bar with Scanner
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(productListProvider.notifier)
                                  .searchProducts('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    ref
                        .read(productListProvider.notifier)
                        .searchProducts(value);
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: _openScanner,
                  tooltip: 'Escanear código',
                ),
              ),
            ],
          ),
        ),
        // Product Grid
        Expanded(
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Text(
                    'No se encontraron productos',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              // Flatten products and variants into grid items
              final List<ProductGridItem> gridItems = [];
              for (final product in products) {
                final sellableVariants =
                    product.variants?.where((v) => v.isForSale).toList() ?? [];

                if (sellableVariants.isNotEmpty) {
                  // Add each sellable variant as a separate grid item
                  for (final variant in sellableVariants) {
                    gridItems.add(
                      ProductGridItem(product: product, variant: variant),
                    );
                  }
                } else {
                  // Add product without variant
                  gridItems.add(ProductGridItem(product: product));
                }
              }

              // Determinar número de columnas según el tamaño
              final crossAxisCount = widget.isMobile ? 2 : 4;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: gridItems.length,
                itemBuilder: (context, index) {
                  final item = gridItems[index];
                  return ProductCard(
                    product: item.product,
                    variant: item.variant,
                    isMobile: widget.isMobile,
                    onTap: () async {
                      // Add directly to cart without dialog
                      final error = await ref
                          .read(pOSProvider.notifier)
                          .addToCart(item.product, variant: item.variant);

                      if (error != null && context.mounted) {
                        _showStockError(context, error);
                      } else if (context.mounted) {
                        _showProductAdded(context, item.displayName);
                      }
                    },
                  );
                },
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
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              productName,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade800,
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
            const Icon(Icons.warning_amber, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
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
