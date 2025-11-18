import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/widgets/category_form.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final departments = ref.watch(departmentListProvider);

    void navigateToForm([Category? category]) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryForm(category: category),
        ),
      );
    }

    void confirmDelete(BuildContext context, WidgetRef ref, Category category) {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                ),
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: categoriesAsync.when(
        data: (categories) => CustomDataTable<Category>(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Código')),
            DataColumn(label: Text('Departamento')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: categories.map((category) {
            final departmentName = departments.asData?.value
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
                        onPressed: () => navigateToForm(category),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: AppTheme.error,
                          size: 20,
                        ),
                        tooltip: 'Eliminar Categoría',
                        onPressed: () => confirmDelete(context, ref, category),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
          itemCount: categories.length,
          onAddItem: () => navigateToForm(),
          emptyText: 'No se encontraron categorías. ¡Añade una para empezar!',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
