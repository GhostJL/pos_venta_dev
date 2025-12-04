import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar chips de estado (Activo/Inactivo).
///
/// Este widget proporciona una visualización consistente del estado
/// de elementos a través de toda la aplicación.
class StatusChip extends StatelessWidget {
  /// Indica si el elemento está activo
  final bool isActive;

  /// Texto personalizado para el estado activo (por defecto: "Activo")
  final String? activeText;

  /// Texto personalizado para el estado inactivo (por defecto: "Inactivo")
  final String? inactiveText;

  const StatusChip({
    super.key,
    required this.isActive,
    this.activeText,
    this.inactiveText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayText = isActive
        ? (activeText ?? 'Activo')
        : (inactiveText ?? 'Inactivo');

    // Use tertiary for success-like states
    final activeColor = colorScheme.tertiary;
    final inactiveColor = colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withAlpha(20)
            : inactiveColor.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? activeColor.withAlpha(50)
              : inactiveColor.withAlpha(50),
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: isActive ? activeColor : inactiveColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
