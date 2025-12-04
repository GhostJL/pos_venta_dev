import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';

void confirmDelete(BuildContext context, WidgetRef ref, item) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmar Eliminación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Está seguro de que desea eliminar este registro de inventario?',
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ref.read(inventoryProvider.notifier).deleteInventory(item.id!);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Inventario eliminado'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      );
    },
  );
}
