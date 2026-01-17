import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/pos_product_item.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/mobile_product_item.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_item_model.dart';

class ProductGridView extends StatelessWidget {
  final List<ProductGridItem> items;
  final bool isMobile;
  final Function(ProductGridItem) onItemTap;
  final Function(ProductGridItem) onItemLongPress;
  final Function(ProductGridItem)? onItemRemove;
  final Function(ProductGridItem)? onItemDelete;
  final Map<int, Map<int?, double>> cartQuantities;

  const ProductGridView({
    super.key,
    required this.items,
    required this.isMobile,
    required this.onItemTap,
    required this.onItemLongPress,
    this.onItemRemove,
    this.onItemDelete,
    required this.cartQuantities,
  });

  // Define el ancho mínimo ideal para que cada tarjeta se vea bien.
  // Un valor de 180.0 a 200.0 suele ser ideal para tarjetas de producto en POS.
  static const double _minItemWidth = 190.0;

  // Define la relación de aspecto ideal (ancho / alto).
  // Si la tarjeta moderna sugerida tiene 120 (imagen) + 100 (contenido) = 220 de alto
  // y un ancho mínimo de 190, la proporción es 190 / 220 ≈ 0.86
  // Ajuste para soporte de imágenes e layout vertical: ~0.65
  static const double _idealAspectRatio = 0.6;

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

    if (isMobile) {
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final quantity =
              cartQuantities[item.product.id]?[item.variant?.id] ?? 0;

          return MobileProductItem(
            product: item.product,
            variant: item.variant,
            quantityInCart: quantity,
            onTap: () => onItemTap(item),
            onLongPress: () => onItemLongPress(item),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      // Cache items off-screen for smoother scrolling on Desktop
      cacheExtent: 500,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _minItemWidth,
        childAspectRatio: _idealAspectRatio,

        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final quantity =
            cartQuantities[item.product.id]?[item.variant?.id] ?? 0;

        return PosProductItem(
          product: item.product,
          variant: item.variant,
          quantityInCart: quantity,
          onTap: () => onItemTap(item),
          onRemove: onItemRemove != null ? () => onItemRemove!(item) : null,
          onDelete: onItemDelete != null ? () => onItemDelete!(item) : null,
          onLongPress: () => onItemLongPress(item),
        );
      },
    );
  }
}
