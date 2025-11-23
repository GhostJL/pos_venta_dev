import 'package:flutter/material.dart';

/// Widget that displays purchase totals (subtotal, tax, total) in a footer
class PurchaseTotalsFooter extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;

  const PurchaseTotalsFooter({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _TotalRow(label: 'Subtotal:', value: subtotal),
          _TotalRow(label: 'Impuestos:', value: tax),
          const Divider(),
          _TotalRow(
            label: 'TOTAL:',
            value: total,
            isTotal: true,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

/// Internal widget for displaying a total row
class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;
  final Color? color;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              : null,
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: isTotal
              ? TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                )
              : null,
        ),
      ],
    );
  }
}
