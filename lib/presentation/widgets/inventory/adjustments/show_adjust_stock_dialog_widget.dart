import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';

void showAdjustStockDialog(BuildContext context, WidgetRef ref, item) {
  final controller = TextEditingController();
  String adjustmentType = 'add'; // 'add' or 'subtract'

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Ajustar Stock',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock actual: ${item.quantityOnHand}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'add',
                      label: Text('Agregar'),
                      icon: Icon(Icons.add_rounded),
                    ),
                    ButtonSegment(
                      value: 'subtract',
                      label: Text('Restar'),
                      icon: Icon(Icons.remove_rounded),
                    ),
                  ],
                  selected: {adjustmentType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      adjustmentType = newSelection.first;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      adjustmentType == 'add'
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      color: adjustmentType == 'add'
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final adjustment = double.tryParse(controller.text);
                  if (adjustment == null || adjustment <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ingrese una cantidad válida')),
                    );
                    return;
                  }

                  double newQuantity = item.quantityOnHand;
                  if (adjustmentType == 'add') {
                    newQuantity += adjustment;
                  } else {
                    newQuantity -= adjustment;
                    if (newQuantity < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('El stock no puede ser negativo'),
                        ),
                      );
                      return;
                    }
                  }

                  final updatedInventory = item.copyWith(
                    quantityOnHand: newQuantity,
                    updatedAt: DateTime.now(),
                  );

                  ref
                      .read(inventoryProvider.notifier)
                      .updateInventory(updatedInventory);

                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Stock ${adjustmentType == 'add' ? 'agregado' : 'restado'} correctamente',
                      ),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  );
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}
