import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PurchaseItemsFilterDialog extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterSelected;

  const PurchaseItemsFilterDialog({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar Artículos'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterOption(context, 'all', 'Todos'),
          _buildFilterOption(context, 'recent', 'Recientes (últimos 50)'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Cerrar')),
      ],
    );
  }

  Widget _buildFilterOption(BuildContext context, String value, String label) {
    return ListTile(
      title: Text(label),
      leading: Icon(
        currentFilter == value
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color: Theme.of(context).primaryColor,
      ),
      onTap: () {
        onFilterSelected(value);
        context.pop();
      },
    );
  }
}
