import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/core/utils/cart_item_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

class CartItemInfo extends ConsumerWidget {
  final PurchaseItem item;
  final CartItemHelper helper;

  const CartItemInfo({super.key, required this.item, required this.helper});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = helper.variant;
    // final stock = variant?.stock ?? 0; // Removed
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Global Settings
    final settingsAsync = ref.watch(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;

    // Data for margin calculation
    final currentCost = variant?.costPrice ?? 0.0;
    final newCost = item.unitCost;
    // Resolve Selling Price: Variant Price -> Product Base Price * Conversion Factor
    double sellingPrice = variant?.price ?? 0.0;
    if (sellingPrice == 0 && helper.product != null) {
      final basePrice = helper.product!.price;
      final factor = variant?.conversionFactor ?? 1.0;
      sellingPrice = basePrice * factor;
    }

    final hasPriceChange =
        currentCost > 0 && (currentCost - newCost).abs() > 0.01;

    // Margin Calculation: (Price - Cost) / Price
    double margin = 0;
    bool hasValidPrice = sellingPrice > 0;
    if (hasValidPrice) {
      margin = ((sellingPrice - newCost) / sellingPrice) * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Nombre del producto y variantes
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'Producto',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (variant != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        variant.variantName,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 2. Info Row: Stock, Cost History, and Margin
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Margin Chip
            if (hasValidPrice) _MarginChip(margin: margin),

            // Cost History
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasPriceChange)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      '\$${currentCost.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 11,
                      ),
                    ),
                  ),
                Text(
                  '\$${newCost.toStringAsFixed(2)}',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasPriceChange
                        ? (newCost > currentCost
                              ? colorScheme.error
                              : Colors.green)
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _MarginChip extends StatelessWidget {
  final double margin;

  const _MarginChip({required this.margin});

  @override
  Widget build(BuildContext context) {
    final isNegative = margin < 0;
    final isLow = margin < 15; // Arbitrary "low" threshold

    Color color = Colors.green;
    IconData icon = Icons.trending_up;

    if (isNegative) {
      color = Theme.of(context).colorScheme.error;
      icon = Icons.trending_down;
    } else if (isLow) {
      color = Colors.orange;
      icon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'Margen: ${margin.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
