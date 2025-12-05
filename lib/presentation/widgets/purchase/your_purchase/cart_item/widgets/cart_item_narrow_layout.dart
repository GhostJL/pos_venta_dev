import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/core/utils/cart_item_helper.dart';
import 'package:posventa/presentation/widgets/purchase/your_purchase/cart_item/widgets/cart_item_actions.dart';
import 'package:posventa/presentation/widgets/purchase/your_purchase/cart_item/widgets/cart_item_info.dart';
import 'package:posventa/presentation/widgets/purchase/your_purchase/cart_item/widgets/cart_item_quantity_controls.dart';
import 'package:posventa/presentation/widgets/purchase/your_purchase/cart_item/widgets/cart_item_total.dart';

class CartItemNarrowLayout extends StatelessWidget {
  final PurchaseItem item;
  final CartItemHelper helper;
  final int index;
  final Function(int index) onEditItem;
  final Function(int index) onRemoveItem;
  final Function(int index, double newQuantity) onQuantityChanged;

  const CartItemNarrowLayout({
    super.key,
    required this.item,
    required this.helper,
    required this.index,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CartItemInfo(item: item, helper: helper),
            ),
            CartItemActions(
              index: index,
              onEditItem: onEditItem,
              onRemoveItem: onRemoveItem,
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Theme.of(context).colorScheme.surface,
                Colors.transparent,
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CartItemQuantityControls(
              item: item,
              step: helper.step,
              index: index,
              onQuantityChanged: onQuantityChanged,
            ),
            CartItemTotal(item: item),
          ],
        ),
      ],
    );
  }
}
