import 'dart:ui';
import 'package:flutter/material.dart';

class KeyboardShortcutsHelpOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const KeyboardShortcutsHelpOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onClose,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping inside
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  margin: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.keyboard,
                              color: colorScheme.onPrimaryContainer,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Atajos de Teclado',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              onPressed: onClose,
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(
                                context,
                                'Navegación',
                                Icons.navigation,
                                [
                                  _ShortcutItem(
                                    keys: ['Tab'],
                                    description:
                                        'Navegar al siguiente producto',
                                  ),
                                  _ShortcutItem(
                                    keys: ['Shift', 'Tab'],
                                    description: 'Navegar al producto anterior',
                                  ),
                                  _ShortcutItem(
                                    keys: ['↑', '↓', '←', '→'],
                                    description:
                                        'Navegar en el grid de productos',
                                  ),
                                  _ShortcutItem(
                                    keys: ['Ctrl', 'Tab'],
                                    description: 'Cambiar entre grid y carrito',
                                  ),
                                  _ShortcutItem(
                                    keys: ['↑', '↓'],
                                    description:
                                        'Navegar en el carrito (cuando está enfocado)',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(context, 'Búsqueda', Icons.search, [
                                _ShortcutItem(
                                  keys: ['F2'],
                                  description: 'Enfocar barra de búsqueda',
                                ),
                                _ShortcutItem(
                                  keys: ['Enter'],
                                  description:
                                      'Agregar primer resultado (con texto) o ir a pago (sin texto)',
                                ),
                                _ShortcutItem(
                                  keys: ['↓'],
                                  description: 'Ir al grid desde búsqueda',
                                ),
                                _ShortcutItem(
                                  keys: ['Esc'],
                                  description: 'Salir de búsqueda',
                                ),
                              ]),
                              const SizedBox(height: 24),
                              _buildSection(
                                context,
                                'Acciones de Producto',
                                Icons.shopping_cart,
                                [
                                  _ShortcutItem(
                                    keys: ['Enter'],
                                    description:
                                        'Agregar producto seleccionado al carrito',
                                  ),
                                  _ShortcutItem(
                                    keys: ['Space'],
                                    description:
                                        'Agregar producto seleccionado al carrito',
                                  ),
                                  _ShortcutItem(
                                    keys: ['+'],
                                    description:
                                        'Incrementar cantidad (producto enfocado)',
                                  ),
                                  _ShortcutItem(
                                    keys: ['-'],
                                    description:
                                        'Decrementar cantidad (producto enfocado)',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                context,
                                'Carrito',
                                Icons.receipt_long,
                                [
                                  _ShortcutItem(
                                    keys: ['+'],
                                    description:
                                        'Incrementar cantidad (item enfocado)',
                                  ),
                                  _ShortcutItem(
                                    keys: ['-'],
                                    description:
                                        'Decrementar cantidad (item enfocado)',
                                  ),
                                  _ShortcutItem(
                                    keys: ['Delete'],
                                    description:
                                        'Eliminar item del carrito (item enfocado)',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F10'],
                                    description: 'Limpiar todo el carrito',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                context,
                                'Acciones Globales',
                                Icons.bolt,
                                [
                                  _ShortcutItem(
                                    keys: ['F6'],
                                    description: 'Seleccionar cliente',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F9'],
                                    description: 'Procesar pago',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F5'],
                                    description: 'Procesar pago (alternativa)',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F1'],
                                    description: 'Mostrar/ocultar esta ayuda',
                                  ),
                                  _ShortcutItem(
                                    keys: ['Esc'],
                                    description: 'Cerrar diálogos/desenfoca',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Footer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Presiona Esc o haz clic fuera para cerrar',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<_ShortcutItem> items,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildShortcutRow(context, item)),
      ],
    );
  }

  Widget _buildShortcutRow(BuildContext context, _ShortcutItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Keys
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: item.keys.map((key) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    key,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 16),
          // Description
          Expanded(
            flex: 3,
            child: Text(
              item.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem {
  final List<String> keys;
  final String description;

  _ShortcutItem({required this.keys, required this.description});
}
