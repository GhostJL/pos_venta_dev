import 'package:flutter/material.dart';

/// A reusable widget that displays a summary of sale totals
class SaleTotalsSummary extends StatelessWidget {
  final int subtotalCents;
  final int discountCents;
  final int taxCents;
  final int totalCents;
  final bool isCompact;
  final bool showDivider;

  const SaleTotalsSummary({
    super.key,
    required this.subtotalCents,
    required this.discountCents,
    required this.taxCents,
    required this.totalCents,
    this.isCompact = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(
          context,
          'Subtotal',
          subtotalCents / 100,
          textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        if (discountCents > 0) ...[
          const SizedBox(height: 8),
          _buildRow(
            context,
            'Descuento',
            -(discountCents / 100),
            textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (taxCents > 0) ...[
          const SizedBox(height: 8),
          _buildRow(
            context,
            'Impuestos',
            taxCents / 100,
            textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 8),
        _buildRow(
          context,
          'Total',
          totalCents / 100,
          textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
            letterSpacing: -0.5,
          ),
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    double amount,
    TextStyle? amountStyle, {
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final labelStyle = isTotal
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(
          '${amount < 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: amountStyle?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
