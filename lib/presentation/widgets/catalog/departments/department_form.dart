import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/widgets/common/generic_form_scaffold.dart';
import 'package:posventa/presentation/widgets/common/simple_dialog_form.dart';

import 'package:posventa/core/constants/ui_constants.dart';

class DepartmentForm extends ConsumerStatefulWidget {
  final Department? department;
  final bool isDialog;

  const DepartmentForm({super.key, this.department, this.isDialog = false});

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
        int? newId;
        if (widget.department == null) {
          newId = await ref
              .read(departmentListProvider.notifier)
              .addDepartment(department);
        } else {
          await ref
              .read(departmentListProvider.notifier)
              .updateDepartment(department);
        }
        if (mounted) {
          Navigator.of(context).pop(newId);
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
    var title = widget.department == null
        ? 'Nuevo Departamento'
        : 'Editar Departamento';
    var submitText = widget.department == null ? 'Crear' : 'Actualizar';

    var formContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: _name,
          textInputAction: TextInputAction.next,
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
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
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
    );

    if (widget.isDialog) {
      return SimpleDialogForm(
        title: title,
        isLoading: _isLoading,
        onSubmit: _submit,
        submitButtonText: submitText, // Used internally in simple dialog
        formKey: _formKey,
        child: formContent,
      );
    }

    return GenericFormScaffold(
      title: title,
      isLoading: _isLoading,
      onSubmit: _submit,
      submitButtonText: submitText,
      formKey: _formKey,
      child: formContent,
    );
  }
}
