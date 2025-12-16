import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/pos_product_item.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_item_model.dart';

class ProductGridView extends StatelessWidget {
  final List<ProductGridItem> items;
  final bool isMobile;
  final Function(ProductGridItem) onItemTap;

  const ProductGridView({
    super.key,
    required this.items,
    required this.isMobile,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron productos',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Determinar número de columnas según el tamaño
    final crossAxisCount = isMobile ? 2 : 4;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return PosProductItem(
          product: item.product,
          variant: item.variant,
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}
