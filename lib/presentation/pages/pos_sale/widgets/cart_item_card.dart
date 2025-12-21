import 'package:flutter/material.dart';

class CartItemCard extends StatelessWidget {
  final String productName;
  final String? variantName;
  final double pricePerUnit;
  final double total;
  final double quantity;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onLongPress;

  const CartItemCard({
    super.key,
    required this.productName,
    this.variantName,
    required this.pricePerUnit,
    required this.total,
    required this.quantity,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate Gross Unit Price (Total / Quantity) to show "Price + IVA" per unit
    final grossPricePerUnit = quantity > 0 ? total / quantity : 0.0;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name & Delete
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (variantName != null && variantName!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            variantName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onRemove,
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Body: Quantity & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quantity Controls
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QuantityButton(icon: Icons.remove, onTap: onDecrement),
                        Container(
                          constraints: const BoxConstraints(minWidth: 32),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            quantity % 1 == 0
                                ? quantity.toStringAsFixed(0)
                                : quantity
                                      .toStringAsFixed(3)
                                      .replaceAll(
                                        RegExp(r'([.]*0)(?!.*\d)'),
                                        '',
                                      ),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _QuantityButton(icon: Icons.add, onTap: onIncrement),
                      ],
                    ),
                  ),

                  // Prices
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$${total.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${grossPricePerUnit.toStringAsFixed(2)} x un.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 20, color: colorScheme.onSurface),
      ),
    );
  }
}
