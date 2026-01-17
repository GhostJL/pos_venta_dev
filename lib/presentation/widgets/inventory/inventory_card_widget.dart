import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/warehouse.dart';

class InventoryCardWidget extends StatelessWidget {
  final Inventory inventory;
  final Product product;
  final ProductVariant variant;
  final Warehouse? warehouse;

  const InventoryCardWidget({
    super.key,
    required this.inventory,
    required this.product,
    required this.variant,
    this.warehouse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stock = inventory.quantityOnHand;
    final min = inventory.minStock ?? variant.stockMin ?? 0.0;

    Color statusColor = Colors.green;
    String statusText = 'En Stock';

    if (stock <= 0) {
      statusColor = theme.colorScheme.error;
      statusText = 'Agotado';
    } else if (stock <= min) {
      statusColor = Colors.orange;
      statusText = 'Bajo Stock';
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon / Image Placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (variant.variantName.isNotEmpty)
                        Text(
                          variant.variantName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      Text(
                        'SKU: ${variant.barcode ?? 'N/A'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  context,
                  'Existencia',
                  stock.toStringAsFixed(2),
                ),
                _buildInfoColumn(
                  context,
                  'Costo',
                  '\$${(variant.costPriceCents / 100).toStringAsFixed(2)}',
                ),
                _buildInfoColumn(
                  context,
                  'Precio',
                  '\$${(variant.priceCents / 100).toStringAsFixed(2)}',
                ),
              ],
            ),
            if (warehouse != null) ...[
              const SizedBox(height: 8),
              Text(
                'Almacén: ${warehouse!.name}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
