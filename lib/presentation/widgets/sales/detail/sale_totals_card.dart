import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/sale.dart';

class SaleTotalsCard extends StatelessWidget {
  final Sale sale;

  const SaleTotalsCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
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
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL A PAGAR',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '\$${(sale.totalCents / 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ],
        ),
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
