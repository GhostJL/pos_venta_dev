import 'package:flutter/material.dart';

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
            color: isTotal ? Colors.grey.shade800 : Colors.grey.shade600,
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
    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildTotalRow(
              'Total',
              totalCents,
              isTotal: true,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
