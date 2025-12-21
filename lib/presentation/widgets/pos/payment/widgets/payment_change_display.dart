import 'package:flutter/material.dart';

class PaymentChangeDisplay extends StatelessWidget {
  final double change;

  const PaymentChangeDisplay({super.key, required this.change});

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // We update semantics: if change is positive (>=0), it's neutral/good (we owe or exact).
    // If negative (we still need money), we show error color.
    final containerColor = isPositive
        ? colorScheme.surfaceContainer
        : colorScheme.errorContainer;

    final textColor = isPositive
        ? colorScheme.onSurface
        : colorScheme.onErrorContainer;

    return Card(
      elevation: 0,
      color: containerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPositive
            ? BorderSide.none
            : BorderSide(color: colorScheme.error),
      ),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isPositive ? 'Cambio' : 'Faltante',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Text(
              '\$${change.abs().toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
