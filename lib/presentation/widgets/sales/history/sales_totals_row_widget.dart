import 'package:flutter/material.dart';

class SaleTotalsRowWidget extends StatelessWidget {
  final int subtotal;
  final int tax;
  final int total;
  final Color textColor;

  const SaleTotalsRowWidget({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _totalColumn('Subtotal', subtotal, textColor),
        _divider(context),
        _totalColumn('Impuestos', tax, textColor),
        _divider(context),
        _totalColumn('Total', total, textColor, isTotal: true),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Theme.of(context).colorScheme.outline,
    );
  }

  Widget _totalColumn(
    String label,
    int cents,
    Color color, {
    bool isTotal = false,
  }) {
    return Column(
      crossAxisAlignment: isTotal
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: color)),
        const SizedBox(height: 2),
        Text(
          '\$${(cents / 100).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: isTotal ? -0.3 : 0,
            color: isTotal ? null : color,
          ),
        ),
      ],
    );
  }
}
