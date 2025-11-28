import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/widgets/inventory/confirm_delete_widget.dart';
import 'package:posventa/presentation/widgets/inventory/show_adjust_stock_dialog_widget.dart';

void showActions(BuildContext context, WidgetRef ref, item) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.background,
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
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_rounded, color: AppTheme.primary),
              ),
              title: const Text(
                'Editar Inventario',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                context.pop();
                context.push('/inventory/form', extra: item);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sync_alt_rounded,
                  color: AppTheme.secondary,
                ),
              ),
              title: const Text(
                'Ajustar Stock',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                context.pop();
                showAdjustStockDialog(context, ref, item);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_rounded, color: AppTheme.error),
              ),
              title: const Text(
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
