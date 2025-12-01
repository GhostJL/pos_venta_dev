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

  Widget _buildColumn(String label, double value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildColumn('Total Pedido', totalOrdered, Colors.blue.shade700),
            Container(width: 1, height: 28, color: Colors.grey.shade200),
            _buildColumn('Ya Recibido', totalReceived, Colors.green.shade700),
            Container(width: 1, height: 28, color: Colors.grey.shade200),
            _buildColumn('A Recibir', totalPending, Colors.orange.shade700),
          ],
        ),
      ),
    );
  }
}
