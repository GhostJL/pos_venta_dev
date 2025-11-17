import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/domain/entities/category.dart';
import 'package:myapp/presentation/providers/category_providers.dart';
import 'package:myapp/presentation/widgets/custom_data_table.dart';
import 'package:myapp/presentation/widgets/category_form_dialog.dart';
import 'package:myapp/presentation/providers/department_providers.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: categoriesAsync.when(
          data: (categories) => CustomDataTable<Category>(
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Código')),
              DataColumn(label: Text('Departamento')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: categories
                .map((cat) => _createDataRow(context, ref, cat))
                .toList(),
            itemCount: categories.length,
            onAddItem: () => _showCategoryFormDialog(context, ref),
            emptyText: 'No se encontraron categorías. ¡Añade una para empezar!',
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  DataRow _createDataRow(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    final departments = ref.watch(departmentListProvider);
    final departmentName =
        departments.asData?.value
            .firstWhere((d) => d.id == category.departmentId)
            .name ??
        'N/A';

    return DataRow(
      cells: [
        DataCell(
          Text(category.name, style: Theme.of(context).textTheme.bodyLarge),
        ),
        DataCell(
          Text(category.code, style: Theme.of(context).textTheme.bodyMedium),
        ),
        DataCell(Text(departmentName)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                tooltip: 'Editar Categoría',
                onPressed: () =>
                    _showCategoryFormDialog(context, ref, category: category),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_rounded,
                  color: AppTheme.error,
                  size: 20,
                ),
                tooltip: 'Eliminar Categoría',
                onPressed: () =>
                    _showDeleteConfirmation(context, ref, category),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCategoryFormDialog(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final result = await showDialog<Category>(
      context: context,
      builder: (context) => CategoryFormDialog(category: category),
    );

    if (result != null) {
      final notifier = ref.read(categoryListProvider.notifier);
      if (category == null) {
        notifier.addCategory(result);
      } else {
        notifier.updateCategory(result);
      }
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar la categoría "${category.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              child: const Text('Eliminar'),
              onPressed: () {
                ref
                    .read(categoryListProvider.notifier)
                    .deleteCategory(category.id!);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
