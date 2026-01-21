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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow(context, 'Subtotal', sale.subtotalCents / 100),
            const SizedBox(height: 8),
            _buildTotalRow(context, 'Impuestos', sale.taxCents / 100),
            if (sale.discountCents > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow(
                context,
                'Descuento',
                sale.discountCents / 100,
                isDiscount: true,
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                height: 1,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '\$${(sale.totalCents / 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            if (sale.amountPaidCents >= sale.totalCents) ...[
              const SizedBox(height: 16),
              _buildTotalRow(
                context,
                'Pagado',
                sale.amountPaidCents / 100,
                isBold: true,
              ),
              if (sale.amountPaidCents > sale.totalCents) ...[
                const SizedBox(height: 8),
                _buildTotalRow(
                  context,
                  'Cambio',
                  (sale.amountPaidCents - sale.totalCents) / 100,
                  isChange: true,
                  isBold: true,
                ),
              ],
            ],
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
    bool isChange = false,
    bool isBold = false,
  }) {
    Color? valueColor;
    if (isDiscount) {
      valueColor = Theme.of(context).colorScheme.tertiary;
    } else if (isChange) {
      valueColor = Theme.of(context).colorScheme.primary;
    } else {
      valueColor = Theme.of(context).colorScheme.onSurface;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
