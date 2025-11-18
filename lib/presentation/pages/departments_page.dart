import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/presentation/widgets/department_form.dart';

class DepartmentsPage extends ConsumerWidget {
  const DepartmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(departmentListProvider);

    void navigateToForm([Department? department]) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DepartmentForm(department: department),
        ),
      );
    }

    void confirmDelete(BuildContext context, WidgetRef ref, Department department) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text(
              '¿Estás seguro de que quieres eliminar el departamento "${department.name}"?',
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
      padding: const EdgeInsets.all(16.0),
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
                  Text(department.name, style: Theme.of(context).textTheme.bodyLarge),
                ),
                DataCell(
                  Text(department.code, style: Theme.of(context).textTheme.bodyMedium),
                ),
                DataCell(_buildStatusChip(department.isActive)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        tooltip: 'Editar Departamento',
                        onPressed: () => navigateToForm(department),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: AppTheme.error,
                          size: 20,
                        ),
                        tooltip: 'Eliminar Departamento',
                        onPressed: () => confirmDelete(context, ref, department),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
          itemCount: departments.length,
          onAddItem: () => navigateToForm(),
          emptyText: 'No se encontraron departamentos. ¡Añade uno para empezar!',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Chip(
      label: Text(isActive ? 'Activo' : 'Inactivo'),
      backgroundColor: isActive
          ? AppTheme.success.withAlpha(10)
          : AppTheme.error.withAlpha(10),
      labelStyle: TextStyle(
        color: isActive ? AppTheme.success : AppTheme.error,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
