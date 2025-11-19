import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';

class CategoryForm extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryForm({super.key, this.category});

  @override
  CategoryFormState createState() => CategoryFormState();
}

class CategoryFormState extends ConsumerState<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  int? _selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _code = widget.category?.code ?? '';
    _selectedDepartmentId = widget.category?.departmentId;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final category = Category(
        id: widget.category?.id,
        name: _name,
        code: _code,
        departmentId: _selectedDepartmentId!,
      );
      if (widget.category == null) {
        ref.read(categoryListProvider.notifier).addCategory(category);
      } else {
        ref.read(categoryListProvider.notifier).updateCategory(category);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final departmentsAsync = ref.watch(departmentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Nueva Categoría' : 'Editar Categoría',
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Categoría',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre de categoría';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _code,
                decoration: const InputDecoration(
                  labelText: 'Código de la Categoría',
                  prefixIcon: Icon(Icons.qr_code_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un código de categoría';
                  }
                  return null;
                },
                onSaved: (value) => _code = value!,
              ),
              const SizedBox(height: 20),
              departmentsAsync.when(
                data: (departments) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedDepartmentId,
                    decoration: const InputDecoration(
                      labelText: 'Departamento',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                    items: departments
                        .map(
                          (Department department) => DropdownMenuItem<int>(
                            value: department.id,
                            child: Text(department.name),
                          ),
                        )
                        .toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedDepartmentId = newValue;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Por favor, selecciona un departamento'
                        : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Text('Error al cargar departamentos: $err'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            widget.category == null
                ? 'Crear Categoría'
                : 'Actualizar Categoría',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
