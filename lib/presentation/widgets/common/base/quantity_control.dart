import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/common/base/base_button.dart';

/// Widget reutilizable para controles de cantidad.
///
/// Muestra un control con botones de incremento/decremento y el valor actual.
/// Patrón: [- botón] [valor] [+ botón]
class QuantityControl extends StatelessWidget {
  /// Valor actual
  final double value;

  /// Incremento/decremento por paso
  final double step;

  /// Valor mínimo permitido (opcional)
  final double? minValue;

  /// Valor máximo permitido (opcional)
  final double? maxValue;

  /// Callback cuando cambia el valor
  final ValueChanged<double> onChanged;

  /// Número de decimales a mostrar (default: 0)
  final int decimals;

  /// Border radius del contenedor (default: 12)
  final double borderRadius;

  /// Color del borde (opcional)
  final Color? borderColor;

  /// Color de fondo (opcional)
  final Color? backgroundColor;

  /// Ancho mínimo del display de valor (default: 40)
  final double minDisplayWidth;

  const QuantityControl({
    super.key,
    required this.value,
    required this.step,
    required this.onChanged,
    this.minValue,
    this.maxValue,
    this.decimals = 0,
    this.borderRadius = 12,
    this.borderColor,
    this.backgroundColor,
    this.minDisplayWidth = 40,
  });

  bool get _canDecrement {
    if (minValue == null) return true;
    return value > minValue!;
  }

  bool get _canIncrement {
    if (maxValue == null) return true;
    return value < maxValue!;
  }

  void _decrement() {
    if (_canDecrement) {
      final newValue = value - step;
      onChanged(
        minValue != null && newValue < minValue! ? minValue! : newValue,
      );
    }
  }

  void _increment() {
    if (_canIncrement) {
      final newValue = value + step;
      onChanged(
        maxValue != null && newValue > maxValue! ? maxValue! : newValue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBorderColor = borderColor ?? colorScheme.outline;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BaseButton.icon(
            icon: Icons.remove_rounded,
            onPressed: _canDecrement ? _decrement : null,
          ),
          Container(
            constraints: BoxConstraints(minWidth: minDisplayWidth),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              value.toStringAsFixed(decimals),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: colorScheme.primary,
              ),
            ),
          ),
          BaseButton.icon(
            icon: Icons.add_rounded,
            onPressed: _canIncrement ? _increment : null,
          ),
        ],
      ),
    );
  }
}
