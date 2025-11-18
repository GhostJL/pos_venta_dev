import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/department_providers.dart';

class DepartmentForm extends ConsumerStatefulWidget {
  final Department? department;

  const DepartmentForm({super.key, this.department});

  @override
  DepartmentFormState createState() => DepartmentFormState();
}

class DepartmentFormState extends ConsumerState<DepartmentForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;

  @override
  void initState() {
    super.initState();
    _name = widget.department?.name ?? '';
    _code = widget.department?.code ?? '';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final department = Department(id: widget.department?.id, name: _name, code: _code);
      if (widget.department == null) {
        ref.read(departmentListProvider.notifier).addDepartment(department);
      } else {
        ref.read(departmentListProvider.notifier).updateDepartment(department);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.department == null ? 'Nuevo Departamento' : 'Editar Departamento'),
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
                  labelText: 'Nombre del Departamento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre de departamento';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _code,
                decoration: const InputDecoration(
                  labelText: 'Código del Departamento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un código de departamento';
                  }
                  return null;
                },
                onSaved: (value) => _code = value!,
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
          ),
          child: Text(widget.department == null ? 'Crear' : 'Actualizar'),
        ),
      ),
    );
  }
}
