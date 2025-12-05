import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/widgets/purchase/your_purchase/quantity_button_widget.dart';

class CartItemQuantityControls extends StatelessWidget {
  final PurchaseItem item;
  final double step;
  final int index;
  final Function(int index, double newQuantity) onQuantityChanged;

  const CartItemQuantityControls({
    super.key,
    required this.item,
    required this.step,
    required this.index,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuantityButtonWidget(
            icon: Icons.remove_rounded,
            onPressed: item.quantity > step
                ? () => onQuantityChanged(index, item.quantity - step)
                : null,
          ),
          Container(
            constraints: BoxConstraints(minWidth: 40),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              item.quantity.toStringAsFixed(0),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          QuantityButtonWidget(
            icon: Icons.add_rounded,
            onPressed: () => onQuantityChanged(index, item.quantity + step),
          ),
        ],
      ),
    );
  }
}
