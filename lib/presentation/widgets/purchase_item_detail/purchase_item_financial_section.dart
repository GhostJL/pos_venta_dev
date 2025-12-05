import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

class PurchaseItemFinancialSection extends StatelessWidget {
  final PurchaseItem item;

  const PurchaseItemFinancialSection({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Información Financiera', Icons.payments),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  'Subtotal',
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  Icons.calculate,
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  'Impuestos',
                  '\$${item.tax.toStringAsFixed(2)}',
                  Icons.receipt,
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  'TOTAL',
                  '\$${item.total.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  isHighlighted: true,
                ),
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
