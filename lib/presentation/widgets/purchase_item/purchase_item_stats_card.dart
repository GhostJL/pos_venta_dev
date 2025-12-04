import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

/// Widget to display purchase item statistics
/// Useful for POS dashboard and reporting
class PurchaseItemStatsCard extends StatelessWidget {
  final List<PurchaseItem> items;

  const PurchaseItemStatsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate statistics
    final totalItems = items.length;
    final totalQuantity = items.fold<double>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final totalValue = items.fold<double>(0, (sum, item) => sum + item.total);
    final averageCost = totalItems > 0 ? totalValue / totalItems : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.primaryColor, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Estadísticas de Artículos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.inventory_2,
                    label: 'Total Artículos',
                    value: totalItems.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    icon: Icons.shopping_cart,
                    label: 'Cantidad Total',
                    value: totalQuantity.toStringAsFixed(0),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.attach_money,
                    label: 'Valor Total',
                    value: '\$${totalValue.toStringAsFixed(2)}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    icon: Icons.calculate,
                    label: 'Costo Promedio',
                    value: '\$${averageCost.toStringAsFixed(2)}',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
