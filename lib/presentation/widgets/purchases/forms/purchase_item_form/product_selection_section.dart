import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/viewmodels/product_variant_item.dart';

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
              // Flatten products and variants into a single list
              final List<ProductVariantItem> items = [];
              for (final product in products) {
                if (product.variants != null && product.variants!.isNotEmpty) {
                  // Add each variant as a separate item
                  for (final variant in product.variants!) {
                    items.add(
                      ProductVariantItem(product: product, variant: variant),
                    );
                  }
                } else {
                  // Add product without variant
                  items.add(ProductVariantItem(product: product));
                }
              }
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
