import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase.dart';

/// Widget reutilizable para mostrar el badge de estado de una compra.
///
/// Muestra el estado de la compra con colores y texto apropiados:
/// - PENDIENTE (naranja)
/// - COMPLETADA (verde)
/// - CANCELADA (rojo)
/// - PARCIAL (azul)
class PurchaseStatusBadge extends StatelessWidget {
  final PurchaseStatus status;

  const PurchaseStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case PurchaseStatus.pending:
        color = Colors.orange;
        text = 'PENDIENTE';
        break;
      case PurchaseStatus.completed:
        color = Colors.green;
        text = 'COMPLETADA';
        break;
      case PurchaseStatus.cancelled:
        color = Colors.red;
        text = 'CANCELADA';
        break;
      case PurchaseStatus.partial:
        color = Colors.blue;
        text = 'PARCIAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
