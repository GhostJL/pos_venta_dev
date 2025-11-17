import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';

class DepartmentsPage extends ConsumerWidget {
  const DepartmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(departmentListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: departmentsAsync.when(
          data: (departments) => CustomDataTable<Department>(
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Código')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: departments
                .map((dept) => _createDataRow(context, ref, dept))
                .toList(),
            itemCount: departments.length,
            onAddItem: () => _showDepartmentDialog(context, ref),
            emptyText:
                'No se encontraron departamentos. ¡Añade uno para empezar!',
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
    Department department,
  ) {
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
                onPressed: () =>
                    _showDepartmentDialog(context, ref, department: department),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_rounded,
                  color: AppTheme.error,
                  size: 20,
                ),
                tooltip: 'Eliminar Departamento',
                onPressed: () =>
                    _showDeleteConfirmation(context, ref, department.id!),
              ),
            ],
          ),
        ),
      ],
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

  void _showDepartmentDialog(
    BuildContext context,
    WidgetRef ref, {
    Department? department,
  }) {
    showDialog(
      context: context,
      builder: (context) => DepartmentFormDialog(department: department),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    int departmentId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este departamento? Esta acción no se puede deshacer.',
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
                    .read(departmentListProvider.notifier)
                    .deleteDepartment(departmentId);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DepartmentFormDialog extends ConsumerStatefulWidget {
  final Department? department;

  const DepartmentFormDialog({super.key, this.department});

  @override
  ConsumerState<DepartmentFormDialog> createState() =>
      _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends ConsumerState<DepartmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.department?.name ?? '',
    );
    _codeController = TextEditingController(
      text: widget.department?.code ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.department?.description ?? '',
    );
    _isActive = widget.department?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final department = Department(
        id: widget.department?.id,
        name: _nameController.text,
        code: _codeController.text,
        description: _descriptionController.text,
        isActive: _isActive,
        displayOrder: widget.department?.displayOrder ?? 0,
      );

      if (widget.department == null) {
        ref.read(departmentListProvider.notifier).addDepartment(department);
      } else {
        ref.read(departmentListProvider.notifier).updateDepartment(department);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.department == null
            ? 'Añadir Departamento'
            : 'Editar Departamento',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v!.isEmpty ? 'Por favor, introduce un nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Código'),
                validator: (v) =>
                    v!.isEmpty ? 'Por favor, introduce un código' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activo'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
