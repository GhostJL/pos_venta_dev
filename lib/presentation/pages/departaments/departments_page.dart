import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/widgets/common/tables/custom_data_table.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/status_chip.dart';
import 'package:posventa/presentation/widgets/common/data_table_actions.dart';

class DepartmentsPage extends ConsumerStatefulWidget {
  const DepartmentsPage({super.key});

  @override
  ConsumerState<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends ConsumerState<DepartmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(departmentListProvider);
    });
  }

  void _navigateToForm([Department? department]) {
    context.push('/departments/form', extra: department);
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Department department,
  ) {
    ConfirmDeleteDialog.show(
      context: context,
      itemName: department.name,
      itemType: 'el departamento',
      onConfirm: () {
        ref
            .read(departmentListProvider.notifier)
            .deleteDepartment(department.id!);
      },
      successMessage: 'Departamento eliminado correctamente',
    );
  }

  @override
  Widget build(BuildContext context) {
    final departmentsAsync = ref.watch(departmentListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: departmentsAsync.when(
        data: (departments) => CustomDataTable<Department>(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Código')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: departments.map((department) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    department.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    department.code,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                DataCell(StatusChip(isActive: department.isActive)),
                DataCell(
                  DataTableActions(
                    hasEditPermission: hasManagePermission,
                    hasDeletePermission: hasManagePermission,
                    onEdit: () => _navigateToForm(department),
                    onDelete: () => _confirmDelete(context, ref, department),
                    editTooltip: 'Editar Departamento',
                    deleteTooltip: 'Eliminar Departamento',
                  ),
                ),
              ],
            );
          }).toList(),
          itemCount: departments.length,
          onAddItem: hasManagePermission ? () => _navigateToForm() : () {},
          emptyText:
              'No se encontraron departamentos. ¡Añade uno para empezar!',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
