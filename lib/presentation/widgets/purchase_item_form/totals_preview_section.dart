import 'package:flutter/material.dart';

class TotalsPreviewSection extends StatelessWidget {
  final String quantity;
  final String unitCost;

  const TotalsPreviewSection({
    super.key,
    required this.quantity,
    required this.unitCost,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity.isEmpty ||
        unitCost.isEmpty ||
        double.tryParse(quantity) == null ||
        double.tryParse(unitCost) == null) {
      return const SizedBox.shrink();
    }

    final qty = double.parse(quantity);
    final cost = double.parse(unitCost);
    final subtotal = qty * cost;

    return Card(
      color: Theme.of(context).primaryColor.withAlpha(100),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Impuestos:'),
                Text(
                  '\$0.00',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
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
