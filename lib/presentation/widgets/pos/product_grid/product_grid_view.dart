import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/shared/product_card.dart';
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
      return const Center(
        child: Text(
          'No se encontraron productos',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Determinar número de columnas según el tamaño
    final crossAxisCount = isMobile ? 2 : 4;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ProductCard(
          product: item.product,
          variant: item.variant,
          isMobile: isMobile,
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}
