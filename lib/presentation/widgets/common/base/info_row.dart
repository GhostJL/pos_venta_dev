import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar filas de información.
///
/// Muestra un patrón común de: [icono] label: valor
/// Usado en cards de detalle para mostrar información estructurada.
class InfoRow extends StatelessWidget {
  /// Icono opcional a mostrar al inicio
  final IconData? icon;

  /// Label descriptivo
  final String label;

  /// Valor a mostrar
  final String value;

  /// Si es true, muestra el valor en color de error
  final bool isError;

  /// Ancho fijo para el label (opcional, para alineación)
  final double? labelWidth;

  /// Tamaño del icono (default: 16)
  final double iconSize;

  /// Tamaño de fuente del label (default: 13)
  final double labelFontSize;

  /// Tamaño de fuente del valor (default: 13)
  final double valueFontSize;

  /// Color personalizado del valor (opcional)
  final Color? valueColor;

  /// Si el valor debe estar en negrita
  final bool valueBold;

  const InfoRow({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.isError = false,
    this.labelWidth,
    this.iconSize = 16,
    this.labelFontSize = 13,
    this.valueFontSize = 13,
    this.valueColor,
    this.valueBold = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
        ],
        if (labelWidth != null)
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: valueBold ? FontWeight.w600 : FontWeight.normal,
              color: isError
                  ? colorScheme.error
                  : valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar un campo de información en formato vertical.
///
/// Muestra label arriba y valor abajo, útil en layouts compactos.
class InfoField extends StatelessWidget {
  /// Label descriptivo
  final String label;

  /// Valor a mostrar
  final String value;

  /// Tamaño de fuente del label (default: 12)
  final double labelFontSize;

  /// Tamaño de fuente del valor (default: 14)
  final double valueFontSize;

  /// Si el valor debe estar en negrita
  final bool valueBold;

  const InfoField({
    super.key,
    required this.label,
    required this.value,
    this.labelFontSize = 12,
    this.valueFontSize = 14,
    this.valueBold = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: valueBold ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
