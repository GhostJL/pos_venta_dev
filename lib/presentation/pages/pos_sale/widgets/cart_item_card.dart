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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Name & Delete
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        productName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                // Variant Name
                if (variantName != null && variantName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    variantName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],

                const SizedBox(height: 4),

                // Price Per Unit
                Text(
                  '\$${pricePerUnit.toStringAsFixed(2)}/unidad',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),

                const SizedBox(height: 12),

                // Bottom Row: Total & Quantity
                Row(
                  children: [
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),

                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: onDecrement,
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              quantity.toStringAsFixed(0),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onTap: onIncrement,
                            isBlue: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isBlue;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.isBlue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isBlue ? Colors.blue[700] : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: isBlue ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
