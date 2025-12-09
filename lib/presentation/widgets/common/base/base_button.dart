import 'package:flutter/material.dart';

/// Variantes de botón disponibles
enum ButtonVariant {
  /// Botón de icono simple con InkWell
  icon,

  /// Botón de acción con borde circular y tooltip
  action,

  /// Botón elevado con label
  elevated,
}

/// Widget base unificado para botones con diferentes variantes.
///
/// Proporciona tres tipos de botones comunes:
/// - `BaseButton.icon`: Botón de icono simple
/// - `BaseButton.action`: Botón de acción con borde circular
/// - `BaseButton.elevated`: Botón elevado con label
class BaseButton extends StatelessWidget {
  /// Icono del botón
  final IconData? icon;

  /// Label del botón (solo para variant elevated)
  final String? label;

  /// Callback cuando se presiona el botón
  final VoidCallback? onPressed;

  /// Variante del botón
  final ButtonVariant variant;

  /// Color del botón/icono
  final Color? color;

  /// Tamaño del icono (default: 18)
  final double iconSize;

  /// Padding del botón (default: EdgeInsets.all(10))
  final EdgeInsets padding;

  /// Border radius (default: 10)
  final double borderRadius;

  /// Tooltip (opcional, principalmente para variant action)
  final String? tooltip;

  const BaseButton({
    super.key,
    this.icon,
    this.label,
    required this.onPressed,
    this.variant = ButtonVariant.icon,
    this.color,
    this.iconSize = 18,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = 10,
    this.tooltip,
  });

  /// Constructor para botón de icono simple
  factory BaseButton.icon({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
    double iconSize = 18,
    EdgeInsets padding = const EdgeInsets.all(10),
    double borderRadius = 10,
  }) {
    return BaseButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      variant: ButtonVariant.icon,
      color: color,
      iconSize: iconSize,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  /// Constructor para botón de acción con borde circular
  factory BaseButton.action({
    Key? key,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required String tooltip,
    double iconSize = 16,
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    return BaseButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      variant: ButtonVariant.action,
      color: color,
      iconSize: iconSize,
      padding: padding,
      borderRadius: 10,
      tooltip: tooltip,
    );
  }

  /// Constructor para botón elevado con label
  factory BaseButton.elevated({
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    double iconSize = 20,
  }) {
    return BaseButton(
      key: key,
      icon: icon,
      label: label,
      onPressed: onPressed,
      variant: ButtonVariant.elevated,
      color: backgroundColor,
      iconSize: iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ButtonVariant.icon:
        return _buildIconButton(context);
      case ButtonVariant.action:
        return _buildActionButton(context);
      case ButtonVariant.elevated:
        return _buildElevatedButton(context);
    }
  }

  Widget _buildIconButton(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF374151);
    final disabledColor = const Color(0xFFD1D5DB);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          child: Icon(
            icon,
            size: iconSize,
            color: onPressed != null ? effectiveColor : disabledColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        customBorder: const CircleBorder(),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: iconSize, color: effectiveColor),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  Widget _buildElevatedButton(BuildContext context) {
    final backgroundColor = color ?? Theme.of(context).colorScheme.primary;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      label: Text(label ?? ''),
    );
  }
}
