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

  Widget _buildColumn(
    String label,
    double value,
    Color valueColor,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)} u',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      surfaceTintColor: Theme.of(context).colorScheme.surface,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildColumn(
              'Total Pedido',
              totalOrdered,
              Theme.of(context).colorScheme.primary,
              context,
            ),
            Container(
              width: 1,
              height: 28,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            _buildColumn(
              'Ya Recibido',
              totalReceived,
              Theme.of(context).colorScheme.tertiary,
              context,
            ),
            Container(
              width: 1,
              height: 28,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            _buildColumn(
              'A Recibir',
              totalPending,
              Theme.of(context).colorScheme.secondary,
              context,
            ),
          ],
        ),
      ),
    );
  }
}
