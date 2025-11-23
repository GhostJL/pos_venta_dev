import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/data_table_actions.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final departments = ref.watch(departmentListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    void navigateToForm([Category? category]) {
      context.push('/categories/form', extra: category);
    }

    void confirmDelete(BuildContext context, WidgetRef ref, Category category) {
      ConfirmDeleteDialog.show(
        context: context,
        itemName: category.name,
        itemType: 'la categoría',
        onConfirm: () {
          ref.read(categoryListProvider.notifier).deleteCategory(category.id!);
        },
        successMessage: 'Categoría eliminada correctamente',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: categoriesAsync.when(
        data: (categories) => CustomDataTable<Category>(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Código')),
            DataColumn(label: Text('Departamento')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: categories.map((category) {
            final departmentName =
                departments.asData?.value
                    .firstWhere((d) => d.id == category.departmentId)
                    .name ??
                'N/A';
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    category.code,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    departmentName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                DataCell(
                  DataTableActions(
                    hasEditPermission: hasManagePermission,
                    hasDeletePermission: hasManagePermission,
                    onEdit: () => navigateToForm(category),
                    onDelete: () => confirmDelete(context, ref, category),
                    editTooltip: 'Editar Categoría',
                    deleteTooltip: 'Eliminar Categoría',
                  ),
                ),
              ],
            );
          }).toList(),
          itemCount: categories.length,
          onAddItem: hasManagePermission ? () => navigateToForm() : () {},
          emptyText: 'No se encontraron categorías. ¡Añade una para empezar!',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
