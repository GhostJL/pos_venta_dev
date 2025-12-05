import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/sale.dart';

class SaleTotalsCard extends StatelessWidget {
  final Sale sale;

  const SaleTotalsCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTotalRow(context, 'Subtotal', sale.subtotalCents / 100),
          const SizedBox(height: 12),
          _buildTotalRow(context, 'Impuestos', sale.taxCents / 100),
          if (sale.discountCents > 0) ...[
            const SizedBox(height: 12),
            _buildTotalRow(
              context,
              'Descuento',
              sale.discountCents / 100,
              isDiscount: true,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '\$${(sale.totalCents / 100).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDiscount
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
