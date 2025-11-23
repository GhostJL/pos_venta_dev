import 'package:flutter/material.dart';

/// Widget reutilizable para cards de formulario centradas.
///
/// Este widget proporciona un layout consistente para formularios
/// que necesitan estar centrados en la pantalla con un diseño de card.
class CenteredFormCard extends StatelessWidget {
  /// Icono a mostrar en la parte superior
  final IconData icon;

  /// Título del formulario
  final String title;

  /// Subtítulo opcional (ej: nombre del usuario)
  final String? subtitle;

  /// Widgets hijos que forman el contenido del formulario
  final List<Widget> children;

  /// Color del icono (por defecto: color primario del tema)
  final Color? iconColor;

  /// Tamaño del icono (por defecto: 64)
  final double iconSize;

  const CenteredFormCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
    this.iconColor,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono
                  Icon(
                    icon,
                    size: iconSize,
                    color: iconColor ?? Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // Título
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Subtítulo (opcional)
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Contenido del formulario
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
