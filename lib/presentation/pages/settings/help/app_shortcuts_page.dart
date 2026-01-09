import 'package:flutter/material.dart';

class AppShortcutsPage extends StatelessWidget {
  const AppShortcutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atajos de Teclado')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _ShortcutSection(
            title: 'Navegación Global',
            shortcuts: [
              _ShortcutItem(
                keys: ['Alt', 'V'],
                description: 'Ir a Ventas (POS)',
              ),
              _ShortcutItem(keys: ['Alt', 'P'], description: 'Ir a Productos'),
              _ShortcutItem(keys: ['Alt', 'C'], description: 'Ir a Clientes'),
              _ShortcutItem(keys: ['Alt', 'I'], description: 'Ir a Inventario'),
              _ShortcutItem(
                keys: ['Alt', 'H'],
                description: 'Ir a Inicio / Dashboard',
              ),
            ],
          ),
          SizedBox(height: 24),
          _ShortcutSection(
            title: 'Punto de Venta (POS)',
            shortcuts: [
              _ShortcutItem(keys: ['F2'], description: 'Buscar producto'),
              _ShortcutItem(keys: ['F6'], description: 'Seleccionar cliente'),
              _ShortcutItem(keys: ['F9', 'F5'], description: 'Cobrar / Pagar'),
              _ShortcutItem(keys: ['F10'], description: 'Limpiar carrito'),
              _ShortcutItem(
                keys: ['Esc'],
                description: 'Cancelar búsqueda / Quitar foco',
              ),
            ],
          ),
          SizedBox(height: 24),
          _ShortcutSection(
            title: 'Pagos',
            shortcuts: [
              _ShortcutItem(
                keys: ['0-9'],
                description: 'Teclado numérico para ingresar monto',
              ),
              _ShortcutItem(keys: ['Enter'], description: 'Confirmar pago'),
              _ShortcutItem(keys: ['Esc'], description: 'Cancelar / Volver'),
              _ShortcutItem(keys: ['Backspace'], description: 'Borrar dígito'),
            ],
          ),
          SizedBox(height: 24),
          _ShortcutSection(
            title: 'Productos',
            shortcuts: [
              _ShortcutItem(keys: ['Ctrl', 'N'], description: 'Nuevo producto'),
              _ShortcutItem(
                keys: ['Ctrl', 'F'],
                description: 'Buscar en la lista',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShortcutSection extends StatelessWidget {
  final String title;
  final List<_ShortcutItem> shortcuts;

  const _ShortcutSection({required this.title, required this.shortcuts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: shortcuts.map((s) => _buildTile(context, s)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, _ShortcutItem item) {
    final isLast = shortcuts.last == item;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: item.keys
                    .map((key) => _buildKeyChange(context, key))
                    .toList(),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  Widget _buildKeyChange(BuildContext context, String key) {
    final isPlus = key == '+' || key.isEmpty;
    if (isPlus) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          '+',
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        key,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface,
          fontFamily: 'monospace', // To look key-like
        ),
      ),
    );
  }
}

class _ShortcutItem {
  final List<String> keys;
  final String description;

  const _ShortcutItem({required this.keys, required this.description});
}
