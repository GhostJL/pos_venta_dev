import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class PosProductItem extends StatelessWidget {
  final Product product;
  final ProductVariant? variant;
  final VoidCallback onTap;

  const PosProductItem({
    super.key,
    required this.product,
    this.variant,
    required this.onTap,
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
      stockColor = colorScheme.error;
    } else if (stock < 10) {
      stockColor = Colors.orange;
    } else {
      stockColor = Colors.green; // Or a specific success color from theme
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      color: Colors.blueAccent,
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

              // Bottom Row: Stock and Add Button
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

                  // Add Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
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
