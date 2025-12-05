import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/core/utils/cart_item_helper.dart';

class CartItemInfo extends StatelessWidget {
  final PurchaseItem item;
  final CartItemHelper helper;

  const CartItemInfo({super.key, required this.item, required this.helper});

  @override
  Widget build(BuildContext context) {
    final priceData = helper.priceData;
    final diff = priceData.cost - priceData.refCost;
    final hasDiff = diff.abs() > 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productName ?? 'Producto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
            height: 1.3,
            letterSpacing: -0.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10),
        if (priceData.hasVariant && helper.variant != null)
          _buildVariantBadge(context, priceData.qty)
        else
          Text(
            '${priceData.qty.toStringAsFixed(priceData.qty % 1 == 0 ? 0 : 2)} ${priceData.unit}',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 1),
              fontWeight: FontWeight.w600,
            ),
          ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              '\$${priceData.cost.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 1),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 4),
            Text(
              'c/u',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 1),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasDiff) ...[
              SizedBox(width: 12),
              _buildDiffBadge(context, diff),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildVariantBadge(BuildContext context, double qty) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              size: 10,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(width: 6),
          Text(
            '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 2)} × ${helper.variant!.description}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 1),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6),
          Text(
            '(${helper.variant!.quantity.toStringAsFixed(0)} u)',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffBadge(BuildContext context, double diff) {
    final isPositive = diff > 0;
    final color = isPositive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.tertiary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 12,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}\$${diff.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
