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

  // Define el ancho mínimo ideal para que cada tarjeta se vea bien.
  // Un valor de 180.0 a 200.0 suele ser ideal para tarjetas de producto en POS.
  static const double _minItemWidth = 190.0;

  // Define la relación de aspecto ideal (ancho / alto).
  // Si la tarjeta moderna sugerida tiene 120 (imagen) + 100 (contenido) = 220 de alto
  // y un ancho mínimo de 190, la proporción es 190 / 220 ≈ 0.86
  static const double _idealAspectRatio = 0.86;

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

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _minItemWidth,
        childAspectRatio: _idealAspectRatio,

        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
