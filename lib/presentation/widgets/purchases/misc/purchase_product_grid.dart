import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/widgets/products/shared/product_card.dart';
import 'package:posventa/presentation/widgets/common/misc/scanner_arguments.dart';
import 'package:posventa/presentation/mixins/search_debounce_mixin.dart';

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

class _PurchaseProductGridState extends ConsumerState<PurchaseProductGrid>
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
          return _handleScannedBarcode(barcode);
        },
      ),
    );
  }

  Future<(bool, String)> _handleScannedBarcode(String barcode) async {
    final productsAsync = ref.read(productListProvider);

    return productsAsync.when(
      data: (products) {
        // final products = state.products; // Removed
        Product? product;
        ProductVariant? matchedVariant;

        for (final p in products) {
          // Check variants first
          if (p.variants != null) {
            final variant = p.variants!
                .where(
                  (v) =>
                      v.barcode == barcode ||
                      (v.additionalBarcodes?.contains(barcode) ?? false),
                )
                .firstOrNull;
            if (variant != null) {
              product = p;
              matchedVariant = variant;
              break;
            }
          }

          // Then check parent
          if (p.barcode == barcode) {
            product = p;
            break;
          }
        }

        if (product != null) {
          widget.onProductSelected(product, matchedVariant);
          return (true, 'Agregado: ${product.name}');
        } else {
          return (false, 'No encontrado: $barcode');
        }
      },
      loading: () => (false, 'Cargando...'),
      error: (_, __) => (false, 'Error al buscar producto'),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              debounceSearch(
                                () => ref
                                    .read(productListProvider.notifier)
                                    .searchProducts(''),
                                duration: Duration.zero,
                              );
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
                    debounceSearch(
                      () => ref
                          .read(productListProvider.notifier)
                          .searchProducts(value),
                      duration: const Duration(milliseconds: 1000),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (Platform.isAndroid || Platform.isIOS)
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
          child: Consumer(
            builder: (context, ref, child) {
              final productsAsync = ref.watch(productListProvider);

              return productsAsync.when(
                data: (products) {
                  // final products = state.products; // Removed
                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron productos',
                        style: TextStyle(color: Color(0xFF9E9E9E)),
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
                        if (variant.type == VariantType.purchase) {
                          gridItems.add(
                            PurchaseGridItem(
                              product: product,
                              variant: variant,
                            ),
                          );
                        }
                      }
                    } else {
                      // Add simple product
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
