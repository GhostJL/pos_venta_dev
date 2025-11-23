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

  Widget _buildRow(String label, double value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)} unidades',
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildRow('Total Pedido:', totalOrdered, Colors.black),
            const SizedBox(height: 4),
            _buildRow('Ya Recibido:', totalReceived, Colors.green.shade700),
            const SizedBox(height: 4),
            _buildRow('A Recibir Ahora:', totalPending, Colors.orange.shade700),
          ],
        ),
      ),
    );
  }
}
