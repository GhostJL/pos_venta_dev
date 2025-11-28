import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
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
            backgroundColor: AppTheme.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Ajustar Stock',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock actual: ${item.quantityOnHand}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
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
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      adjustmentType == 'add'
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      color: adjustmentType == 'add'
                          ? AppTheme.success
                          : AppTheme.error,
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
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final adjustment = double.tryParse(controller.text);
                  if (adjustment == null || adjustment <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingrese una cantidad válida'),
                      ),
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
                        const SnackBar(
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
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}
