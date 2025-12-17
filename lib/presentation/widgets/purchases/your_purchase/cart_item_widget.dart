import 'package:flutter/material.dart';

import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/core/utils/cart_item_helper.dart';
import 'package:posventa/presentation/widgets/purchases/your_purchase/cart_item/widgets/cart_item_narrow_layout.dart';
import 'package:posventa/presentation/widgets/purchases/your_purchase/cart_item/widgets/cart_item_wide_layout.dart';

class CartItemWidget extends StatelessWidget {
  final PurchaseItem item;
  final Product? product;
  final int index;
  final Function(int index) onEditItem;
  final Function(int index) onRemoveItem;
  final Function(int index, double newQuantity) onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.product,
    required this.index,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final helper = CartItemHelper(item: item, product: product);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 520;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onEditItem(index),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: isWide
                      ? CartItemWideLayout(
                          item: item,
                          helper: helper,
                          index: index,
                          onEditItem: onEditItem,
                          onRemoveItem: onRemoveItem,
                          onQuantityChanged: onQuantityChanged,
                        )
                      : CartItemNarrowLayout(
                          item: item,
                          helper: helper,
                          index: index,
                          onEditItem: onEditItem,
                          onRemoveItem: onRemoveItem,
                          onQuantityChanged: onQuantityChanged,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
