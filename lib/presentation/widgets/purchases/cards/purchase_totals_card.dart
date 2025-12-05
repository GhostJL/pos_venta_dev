import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/common/base/base_card.dart';

class PurchaseTotalsCard extends StatelessWidget {
  final int subtotalCents;
  final int taxCents;
  final int totalCents;

  const PurchaseTotalsCard({
    super.key,
    required this.subtotalCents,
    required this.taxCents,
    required this.totalCents,
  });

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    int cents, {
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 13 : 12,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal
                ? Colors.grey.shade800
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '\$${(cents / 100).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _buildTotalRow(
            context,
            'Total',
            totalCents,
            isTotal: true,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
