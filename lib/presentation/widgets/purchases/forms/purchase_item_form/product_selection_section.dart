import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/viewmodels/product_variant_item.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class ProductSelectionSection extends ConsumerWidget {
  final ProductVariantItem? selectedItem;
  final ValueChanged<ProductVariantItem?> onChanged;

  const ProductSelectionSection({
    super.key,
    required this.selectedItem,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del Producto',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ProductVariantItem>(
          initialValue: selectedItem,
          decoration: const InputDecoration(
            labelText: 'Producto / Variante *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.shopping_bag),
          ),
          items: productsAsync.when(
            data: (products) {
              // final products = state.products; // Removed
              // Flatten products and variants into a single list
              final List<ProductVariantItem> items = [];
              for (final product in products) {
                final variants = product.variants ?? [];
                if (variants.isNotEmpty) {
                  // Only add variants explicitly marked for Purchase
                  for (final variant in variants) {
                    if (variant.type == VariantType.purchase) {
                      items.add(
                        ProductVariantItem(product: product, variant: variant),
                      );
                    }
                  }
                } else {
                  // Product has no variants (Simple Product).
                  // Allow it for Purchase as per user request.
                  items.add(ProductVariantItem(product: product));
                }
              }
              // Sort items: Purchase variants first (though now list is mostly purchase)
              items.sort((a, b) {
                if (a.variant?.type == VariantType.purchase &&
                    b.variant?.type != VariantType.purchase) {
                  return -1;
                }
                if (a.variant?.type != VariantType.purchase &&
                    b.variant?.type == VariantType.purchase) {
                  return 1;
                }
                return a.displayName.compareTo(b.displayName);
              });
              return items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList();
            },
            loading: () => [],
            error: (_, __) => [],
          ),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Requerido' : null,
        ),
      ],
    );
  }
}
