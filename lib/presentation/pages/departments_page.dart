import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/presentation/widgets/department_form.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class DepartmentsPage extends ConsumerWidget {
  const DepartmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(departmentListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    void navigateToForm([Department? department]) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DepartmentForm(department: department),
        ),
      );
    }

    void confirmDelete(
      BuildContext context,
      WidgetRef ref,
      Department department,
    ) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Confirmar Eliminación'),
            content: Text(
              '¿Estás seguro de que quieres eliminar el departamento "${department.name}"?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actionsPadding: const EdgeInsets.all(20),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Eliminar'),
                onPressed: () {
                  ref
                      .read(departmentListProvider.notifier)
                      .deleteDepartment(department.id!);
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    }

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
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    department.code,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                DataCell(_buildStatusChip(department.isActive)),
                DataCell(
                  Row(
                    children: [
                      if (hasManagePermission)
                        IconButton(
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          tooltip: 'Editar Departamento',
                          onPressed: () => navigateToForm(department),
                        ),
                      if (hasManagePermission)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: AppTheme.error,
                            size: 20,
                          ),
                          tooltip: 'Eliminar Departamento',
                          onPressed: () =>
                              confirmDelete(context, ref, department),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
          itemCount: departments.length,
          onAddItem: hasManagePermission ? () => navigateToForm() : () {},
          emptyText:
              'No se encontraron departamentos. ¡Añade uno para empezar!',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.success.withAlpha(20)
            : AppTheme.error.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppTheme.success.withAlpha(50)
              : AppTheme.error.withAlpha(50),
        ),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: isActive ? AppTheme.success : AppTheme.error,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
