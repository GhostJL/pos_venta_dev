import 'package:flutter/material.dart';

class PaymentChangeDisplay extends StatelessWidget {
  final double change;

  const PaymentChangeDisplay({super.key, required this.change});

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isPositive
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final textColor = isPositive ? colorScheme.tertiary : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: backgroundColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isPositive ? 'Cambio' : 'Faltante',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Text(
            '\$${change.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
