import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/widgets/common/generic_form_scaffold.dart';

import 'package:posventa/core/constants/ui_constants.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.department?.name ?? '';
    _code = widget.department?.code ?? '';
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final department = Department(
          id: widget.department?.id,
          name: _name,
          code: _code,
        );
        if (widget.department == null) {
          await ref
              .read(departmentListProvider.notifier)
              .addDepartment(department);
        } else {
          await ref
              .read(departmentListProvider.notifier)
              .updateDepartment(department);
        }
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Departamento guardado correctamente'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar el departamento: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericFormScaffold(
      title: widget.department == null
          ? 'Nuevo Departamento'
          : 'Editar Departamento',
      isLoading: _isLoading,
      onSubmit: _submit,
      submitButtonText: widget.department == null
          ? 'Crear Departamento'
          : 'Actualizar Departamento',
      formKey: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(
              labelText: 'Nombre del Departamento',
              prefixIcon: Icon(Icons.business_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, introduce un nombre de departamento';
              }
              if (value.length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          TextFormField(
            initialValue: _code,
            decoration: const InputDecoration(
              labelText: 'Código del Departamento',
              prefixIcon: Icon(Icons.qr_code_rounded),
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
    );
  }
}
