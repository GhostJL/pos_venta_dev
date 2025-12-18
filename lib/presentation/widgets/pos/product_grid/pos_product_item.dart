import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class PosProductItem extends StatelessWidget {
  final Product product;
  final ProductVariant? variant;
  final double quantityInCart;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PosProductItem({
    super.key,
    required this.product,
    this.variant,
    this.quantityInCart = 0,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine effective stock and price
    final int stock = variant != null
        ? (variant!.stock ?? 0).toInt()
        : (product.stock ?? 0);

    final double price = variant != null ? variant!.price : product.price;

    final String displayName = product.name;
    final String? variantName = variant?.description;

    // Stock Color Logic
    Color stockColor;
    if (stock <= 0) {
      stockColor = context.outOfStock;
    } else if (stock < 10) {
      stockColor = context.lowStock;
    } else {
      stockColor = context.inStock;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Price (Right aligned for prominence)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                displayName,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              if (variantName != null && variantName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  variantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const Spacer(),

              // Bottom Row: Stock and Add/Quantity Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stock Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: stockColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      stock <= 0 ? 'Sin Stock' : '$stock Disp.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: stockColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Add/Quantity Button
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: quantityInCart > 0
                              ? colorScheme.secondaryContainer
                              : colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (quantityInCart > 0
                                          ? colorScheme.secondaryContainer
                                          : colorScheme.primary)
                                      .withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add,
                          color: quantityInCart > 0
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      if (quantityInCart > 0)
                        Positioned(
                          top: -8,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              '${quantityInCart.toStringAsFixed(0)} +',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
