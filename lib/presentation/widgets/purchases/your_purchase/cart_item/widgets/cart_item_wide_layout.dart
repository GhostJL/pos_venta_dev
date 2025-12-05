import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/core/utils/cart_item_helper.dart';
import 'package:posventa/presentation/widgets/purchases/your_purchase/cart_item/widgets/cart_item_actions.dart';
import 'package:posventa/presentation/widgets/purchases/your_purchase/cart_item/widgets/cart_item_info.dart';
import 'package:posventa/presentation/widgets/purchases/your_purchase/cart_item/widgets/cart_item_quantity_controls.dart';
import 'package:posventa/presentation/widgets/purchases/your_purchase/cart_item/widgets/cart_item_total.dart';

class CartItemWideLayout extends StatelessWidget {
  final PurchaseItem item;
  final CartItemHelper helper;
  final int index;
  final Function(int index) onEditItem;
  final Function(int index) onRemoveItem;
  final Function(int index, double newQuantity) onQuantityChanged;

  const CartItemWideLayout({
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
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CartItemInfo(item: item, helper: helper),
        ),
        SizedBox(width: 24),
        CartItemQuantityControls(
          item: item,
          step: helper.step,
          index: index,
          onQuantityChanged: onQuantityChanged,
        ),
        SizedBox(width: 24),
        CartItemTotal(item: item),
        SizedBox(width: 12),
        CartItemActions(
          index: index,
          onEditItem: onEditItem,
          onRemoveItem: onRemoveItem,
        ),
      ],
    );
  }
}
