import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

class PurchaseItemInfoSection extends StatelessWidget {
  final PurchaseItem item;
  final DateFormat dateFormat;

  const PurchaseItemInfoSection({
    super.key,
    required this.item,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Información del Producto', Icons.info_outline),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  'Producto',
                  item.productName ?? 'N/A',
                  Icons.shopping_bag,
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  'Cantidad',
                  '${item.quantity} ${item.unitOfMeasure}',
                  Icons.inventory,
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  'Costo Unitario',
                  '\$${item.unitCost.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
                if (item.expirationDate != null) ...[
                  const Divider(),
                  _buildInfoRow(
                    context,
                    'Fecha de Vencimiento',
                    dateFormat.format(item.expirationDate!),
                    Icons.event_busy,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
