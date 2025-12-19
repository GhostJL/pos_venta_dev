import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar el resumen de recepción en el diálogo.
///
/// Muestra:
/// - Total pedido
/// - Ya recibido
/// - A recibir ahora
class ReceptionSummaryCard extends StatelessWidget {
  final double totalOrdered;
  final double totalReceived;
  final double totalPending;

  const ReceptionSummaryCard({
    super.key,
    required this.totalOrdered,
    required this.totalReceived,
    required this.totalPending,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _MetricItem(
                label: 'PEDIDO',
                value: totalOrdered,
                color: colorScheme.primary,
              ),
              VerticalDivider(
                width: 32,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
              _MetricItem(
                label: 'RECIBIDO',
                value: totalReceived,
                color: colorScheme.tertiary,
              ),
              VerticalDivider(
                width: 32,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
              _MetricItem(
                label: 'PENDIENTE',
                value: totalPending,
                color: colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)} u',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
