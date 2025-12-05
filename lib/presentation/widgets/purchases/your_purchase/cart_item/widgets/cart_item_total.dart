import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

class CartItemTotal extends StatelessWidget {
  final PurchaseItem item;

  const CartItemTotal({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${item.total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: -0.5,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Total',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
