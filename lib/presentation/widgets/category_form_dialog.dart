import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/entities/category.dart';
import 'package:myapp/domain/entities/department.dart';
import 'package:myapp/presentation/providers/department_providers.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  late String? _description;
  int? _departmentId;

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _code = widget.category?.code ?? '';
    _description = widget.category?.description;
    _departmentId = widget.category?.departmentId;
  }

  @override
  Widget build(BuildContext context) {
    final departmentsAsync = ref.watch(departmentListProvider);

    return AlertDialog(
      title: Text(widget.category == null ? 'Añadir Categoría' : 'Editar Categoría'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _code,
                decoration: const InputDecoration(labelText: 'Código', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un código';
                  }
                  return null;
                },
                onSaved: (value) => _code = value!,
              ),
              const SizedBox(height: 16),
              departmentsAsync.when(
                data: (departments) {
                  if (departments.isEmpty) {
                    return const Text(
                      'No hay departamentos. Añade un departamento primero.',
                      textAlign: TextAlign.center,
                    );
                  }

                  final validDepartmentId = _departmentId != null && departments.any((d) => d.id == _departmentId)
                      ? _departmentId
                      : null;
                  
                  return DropdownButtonFormField<int>(
                    value: validDepartmentId,
                    items: departments.map((Department department) {
                      return DropdownMenuItem<int>(
                        value: department.id,
                        child: Text(department.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _departmentId = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Departamento',
                      border: OutlineInputBorder(),
                    ),
                     validator: (value) => value == null ? 'Por favor, selecciona un departamento' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error al cargar departamentos: $err'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                onSaved: (value) => _description = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_departmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se ha seleccionado ningún departamento.')),
        );
        return;
      }

      final category = Category(
        id: widget.category?.id,
        name: _name,
        code: _code,
        departmentId: _departmentId!,
        description: _description,
        isActive: widget.category?.isActive ?? true,
      );
      Navigator.of(context).pop(category);
    }
  }
}
