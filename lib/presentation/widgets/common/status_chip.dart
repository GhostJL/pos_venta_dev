import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';

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
    final displayText = isActive
        ? (activeText ?? 'Activo')
        : (inactiveText ?? 'Inactivo');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.success.withAlpha(20)
            : AppTheme.error.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppTheme.success.withAlpha(50)
              : AppTheme.error.withAlpha(50),
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: isActive ? AppTheme.success : AppTheme.error,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
