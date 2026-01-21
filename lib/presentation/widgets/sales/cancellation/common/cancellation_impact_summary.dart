import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/widgets/sales/common/sale_payment_method_chip.dart';

class CancellationImpactSummary extends StatelessWidget {
  final Sale sale;

  const CancellationImpactSummary({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Impacto de la Cancelación',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 1. Inventory Return
            Text(
              'Inventario a Reintegrar',
              style: tt.labelLarge?.copyWith(color: cs.secondary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: sale.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.variantName != null
                                ? '${item.productName} - ${item.variantName}'
                                : item.productName ??
                                      'Producto #${item.productId}',
                            style: tt.bodyMedium,
                          ),
                        ),
                        Text(
                          '+${item.quantity.toStringAsFixed(0)}',
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Refund Info
            Text(
              'Reembolso al Cliente',
              style: tt.labelLarge?.copyWith(color: cs.error),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.error.withValues(alpha: 0.2)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total a devolver:', style: tt.bodyMedium),
                      Text(
                        '\$${(sale.totalCents / 100).toStringAsFixed(2)}',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sale.payments.map((p) {
                      return SalePaymentMethodChip(
                        paymentMethod: p.paymentMethod,
                        amount: p.amountCents / 100,
                        isCompact: true,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: cs.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta acción es irreversible y afectará los reportes de corte de caja.',
                    style: tt.bodySmall?.copyWith(
                      color: cs.tertiary,
                      fontStyle: FontStyle.italic,
                    ),
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
