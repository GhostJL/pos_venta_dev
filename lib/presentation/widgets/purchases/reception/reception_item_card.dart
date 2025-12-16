import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

class ReceptionItemCard extends StatelessWidget {
  final PurchaseItem item;
  final Product? product;
  final ProductVariant? variant;
  final TextEditingController quantityController;
  final TextEditingController lotController;
  final TextEditingController expirationController;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onExpirationTap;

  const ReceptionItemCard({
    super.key,
    required this.item,
    this.product,
    this.variant,
    required this.quantityController,
    required this.lotController,
    required this.expirationController,
    required this.onQuantityChanged,
    required this.onExpirationTap,
  });

  Widget _buildBadge(double value, Color color, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)} $unit',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = item.quantity - item.quantityReceived;

    // Calculate price diff
    double currentCost = 0;
    if (variant != null) {
      currentCost = variant!.costPriceCents / 100.0;
    } else if (product != null) {
      currentCost = product!.costPriceCents / 100.0;
    }

    // Convert item unit cost to pack cost if variant
    double comparisonCost = item.unitCost;
    if (variant != null) {
      comparisonCost = item.unitCost * variant!.quantity;
    }

    final diff = comparisonCost - currentCost;
    final hasDiff = diff.abs() > 0.01 && currentCost > 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      surfaceTintColor: Theme.of(context).colorScheme.surface,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Nombre del producto
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName ?? 'Producto',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (variant != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      '${variant!.quantity.toStringAsFixed(0)} un/caja',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Price Info
            if (hasDiff)
              Row(
                children: [
                  Text(
                    'Costo Anterior: \$${currentCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nuevo: \$${comparisonCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: diff > 0
                          ? Theme.of(context).colorScheme.error
                          : AppTheme.transactionSuccess,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    diff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: diff > 0
                        ? Theme.of(context).colorScheme.error
                        : AppTheme.transactionSuccess,
                  ),
                ],
              )
            else
              Text(
                'Costo: \$${comparisonCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

            const SizedBox(height: 8),

            /// Badges
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildBadge(
                  item.quantity,
                  Theme.of(context).colorScheme.primary,
                  'Solicitado',
                ),
                if (item.quantityReceived > 0)
                  _buildBadge(
                    item.quantityReceived,
                    Theme.of(context).colorScheme.tertiary,
                    'Recibido',
                  ),
                _buildBadge(
                  remaining,
                  Theme.of(context).colorScheme.secondary,
                  'Pendiente',
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Campos de entrada
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cantidad
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Recibir',
                      suffixText: item.unitOfMeasure,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (value) {
                      final qty = double.tryParse(value) ?? 0;
                      onQuantityChanged(qty);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Lote
                Expanded(
                  child: TextField(
                    controller: lotController,
                    decoration: InputDecoration(
                      labelText: 'Lote',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                // Caducidad
                if (product?.hasExpiration ?? false) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      controller: expirationController,
                      readOnly: true,
                      onTap: onExpirationTap,
                      decoration: InputDecoration(
                        labelText: 'Caducidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        suffixIcon: const Icon(Icons.calendar_today, size: 16),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
