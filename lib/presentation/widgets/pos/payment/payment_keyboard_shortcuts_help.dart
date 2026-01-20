import 'dart:ui';
import 'package:flutter/material.dart';

class PaymentKeyboardShortcutsHelp extends StatelessWidget {
  final VoidCallback onClose;

  const PaymentKeyboardShortcutsHelp({super.key, required this.onClose});

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
                  constraints: const BoxConstraints(maxWidth: 700),
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
                                'Atajos de Teclado - Pago',
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
                                'Métodos de Pago',
                                Icons.payment,
                                [
                                  _ShortcutItem(
                                    keys: ['F2', '1'],
                                    description: 'Seleccionar Efectivo',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F3', '2'],
                                    description: 'Seleccionar Tarjeta',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F4', '3'],
                                    description: 'Seleccionar Transferencia',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F5', '4'],
                                    description: 'Seleccionar Crédito',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                context,
                                'Montos Rápidos',
                                Icons.attach_money,
                                [
                                  _ShortcutItem(
                                    keys: ['F6', 'E'],
                                    description: 'Monto Exacto',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F7', '5'],
                                    description: '\$20',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F8', '6'],
                                    description: '\$50',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F9', '7'],
                                    description: '\$100',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F10', '8'],
                                    description: '\$200',
                                  ),
                                  _ShortcutItem(
                                    keys: ['F11', '9'],
                                    description: '\$500',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(context, 'Acciones', Icons.bolt, [
                                _ShortcutItem(
                                  keys: ['Enter'],
                                  description: 'Confirmar pago',
                                ),
                                _ShortcutItem(
                                  keys: ['Esc'],
                                  description: 'Cancelar y volver',
                                ),
                                _ShortcutItem(
                                  keys: ['Backspace'],
                                  description: 'Borrar último dígito',
                                ),
                                _ShortcutItem(
                                  keys: ['C'],
                                  description: 'Limpiar monto',
                                ),
                                _ShortcutItem(
                                  keys: ['0-9', '.'],
                                  description: 'Entrada numérica directa',
                                ),
                              ]),
                              const SizedBox(height: 24),
                              _buildSection(
                                context,
                                'Ayuda',
                                Icons.help_outline,
                                [
                                  _ShortcutItem(
                                    keys: ['F1'],
                                    description: 'Mostrar/ocultar esta ayuda',
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
