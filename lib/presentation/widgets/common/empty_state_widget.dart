import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar estados vacíos.
///
/// Este widget proporciona una visualización consistente cuando
/// no hay datos para mostrar en listas o tablas.
class EmptyStateWidget extends StatelessWidget {
  /// Icono a mostrar
  final IconData icon;

  /// Mensaje descriptivo
  final String message;

  /// Tamaño del icono (por defecto: 64)
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: colorScheme.onSurfaceVariant.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
