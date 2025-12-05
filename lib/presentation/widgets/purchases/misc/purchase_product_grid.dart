import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/widgets/products/shared/product_card.dart';

/// Helper class to represent a product or variant as a single grid item
class PurchaseGridItem {
  final Product product;
  final ProductVariant? variant;

  PurchaseGridItem({required this.product, this.variant});

  String get displayName {
    if (variant != null) {
      return '${product.name}\n${variant!.description}';
    }
    return product.name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseGridItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id &&
          variant?.id == other.variant?.id;

  @override
  int get hashCode => product.id.hashCode ^ (variant?.id.hashCode ?? 0);
}

class PurchaseProductGrid extends ConsumerStatefulWidget {
  final Function(Product, ProductVariant?) onProductSelected;

  const PurchaseProductGrid({super.key, required this.onProductSelected});

  @override
  ConsumerState<PurchaseProductGrid> createState() =>
      _PurchaseProductGridState();
}

class _PurchaseProductGridState extends ConsumerState<PurchaseProductGrid> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openScanner() async {
    final barcode = await context.push<String>('/scanner');
    if (barcode != null && mounted) {
      _handleScannedBarcode(barcode);
    }
  }

  void _handleScannedBarcode(String barcode) {
    final productsAsync = ref.read(productListProvider);

    productsAsync.whenData((products) {
      Product? product;
      ProductVariant? matchedVariant;

      for (final p in products) {
        if (p.barcode == barcode) {
          product = p;
          break;
        }
        if (p.variants != null) {
          final variant = p.variants!
              .where((v) => v.barcode == barcode)
              .firstOrNull;
          if (variant != null) {
            product = p;
            matchedVariant = variant;
            break;
          }
        }
      }

      if (product != null) {
        widget.onProductSelected(product, matchedVariant);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Agregado: ${product.name} ${matchedVariant != null ? "(${matchedVariant.description})" : ""}',
            ),
            duration: const Duration(milliseconds: 800),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto no encontrado: $barcode'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Search Bar with Scanner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos para compra...',
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
                  color: Theme.of(context).primaryColor.withAlpha(20),
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
              final List<PurchaseGridItem> gridItems = [];
              for (final product in products) {
                final variants = product.variants ?? [];

                if (variants.isNotEmpty) {
                  // Add each variant as a separate grid item
                  for (final variant in variants) {
                    gridItems.add(
                      PurchaseGridItem(product: product, variant: variant),
                    );
                  }
                } else {
                  // Add product without variant
                  gridItems.add(PurchaseGridItem(product: product));
                }
              }

              // Determinar número de columnas según el tamaño
              final crossAxisCount = isMobile ? 2 : 3;

              return GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.1, // Slightly taller for cost display
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: gridItems.length,
                itemBuilder: (context, index) {
                  final item = gridItems[index];
                  return ProductCard(
                    product: item.product,
                    variant: item.variant,
                    isMobile: isMobile,
                    showCost: true, // Show cost for purchases
                    onTap: () {
                      widget.onProductSelected(item.product, item.variant);
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
