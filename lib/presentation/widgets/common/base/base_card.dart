import 'package:flutter/material.dart';

/// Widget base reutilizable para todas las cards de la aplicación.
///
/// Proporciona un diseño consistente con configuración flexible para:
/// - BorderRadius personalizable
/// - Padding personalizable
/// - Elevación y bordes
/// - Soporte para onTap opcional
/// - Colores personalizables
class BaseCard extends StatelessWidget {
  /// Contenido de la card
  final Widget child;

  /// Radio de borde (default: 12)
  final double borderRadius;

  /// Padding interno (default: EdgeInsets.all(16))
  final EdgeInsets padding;

  /// Callback cuando se toca la card (opcional)
  final VoidCallback? onTap;

  /// Color de fondo (default: colorScheme.surfaceContainer)
  final Color? backgroundColor;

  /// Elevación de la card (default: 0)
  final double elevation;

  /// Mostrar borde (default: true)
  final bool showBorder;

  /// Color del borde (default: colorScheme.outline)
  final Color? borderColor;

  /// Ancho del borde (default: 1)
  final double borderWidth;

  const BaseCard({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.elevation = 0,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainer;
    final effectiveBorderColor = borderColor ?? colorScheme.outline;

    final cardContent = Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: effectiveBorderColor, width: borderWidth)
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(10),
                  blurRadius: elevation * 4,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Padding(padding: padding, child: child),
                )
              : Padding(padding: padding, child: child),
        ),
      ),
    );

    return cardContent;
  }
}
