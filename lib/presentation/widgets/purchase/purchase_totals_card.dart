import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar el resumen de totales de una compra.
///
/// Muestra en un Card:
/// - Subtotal
/// - Impuestos
/// - Total (destacado)
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

  Widget _buildTotalRow(String label, int cents, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            '\$${(cents / 100).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withAlpha(100),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', subtotalCents),
            _buildTotalRow('Impuestos', taxCents),
            const Divider(),
            _buildTotalRow('Total', totalCents, isTotal: true),
          ],
        ),
      ),
    );
  }
}
