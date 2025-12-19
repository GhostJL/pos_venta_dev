import 'package:flutter/material.dart';

/// Widget that displays purchase totals (subtotal, tax, total) in a footer
class PurchaseTotalsFooter extends StatelessWidget {
  final int itemsCount;
  final double total;

  const PurchaseTotalsFooter({
    super.key,
    required this.itemsCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL DE LA ORDEN',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '$itemsCount Productos en Carrito',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            Text(
              '\$ ${total.toStringAsFixed(2)}',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
