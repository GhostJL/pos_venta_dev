import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/widgets/inventory/confirm_delete_widget.dart';
import 'package:posventa/presentation/widgets/inventory/show_adjust_stock_dialog_widget.dart';

void showActions(BuildContext context, WidgetRef ref, item) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                'Editar Inventario',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                context.pop();
                context.push('/inventory/form', extra: item);
              },
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sync_alt_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: Text(
                'Ajustar Stock',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                context.pop();
                showAdjustStockDialog(context, ref, item);
              },
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              title: Text(
                'Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                context.pop();
                confirmDelete(context, ref, item);
              },
            ),
          ],
        ),
      );
    },
  );
}
