import 'package:flutter/material.dart';

class CartItemWidget extends StatelessWidget {
  final String? productName;
  final String? variantDescription;
  final Function() onPressedRemove;
  final Function() onTapLessProduct;
  final Function() onTapMoreProduct;
  final double quantity;
  final double unitPrice;
  final double total;

  const CartItemWidget({
    super.key,
    required this.productName,
    required this.variantDescription,
    required this.onPressedRemove,
    required this.onTapLessProduct,
    required this.onTapMoreProduct,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header: nombre + eliminar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName ?? '',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (variantDescription != null &&
                          variantDescription!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          variantDescription!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onPressedRemove,
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Body: cantidad + precios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Controles de cantidad
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: onTapLessProduct,
                        context: context,
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 32),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          quantity.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: onTapMoreProduct,
                        context: context,
                      ),
                    ],
                  ),
                ),

                // Precios
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 18,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${unitPrice.toStringAsFixed(2)} x un.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final Function() onTap;
  final BuildContext context;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
