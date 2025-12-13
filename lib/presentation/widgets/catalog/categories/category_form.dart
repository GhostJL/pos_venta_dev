import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/widgets/common/generic_form_scaffold.dart';
import 'package:posventa/presentation/widgets/common/simple_dialog_form.dart';
import 'package:posventa/core/constants/ui_constants.dart';

class CategoryForm extends ConsumerStatefulWidget {
  final Category? category;
  final bool isDialog;

  const CategoryForm({super.key, this.category, this.isDialog = false});

  @override
  CategoryFormState createState() => CategoryFormState();
}

class CategoryFormState extends ConsumerState<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  int? _selectedDepartmentId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _code = widget.category?.code ?? '';
    _selectedDepartmentId = widget.category?.departmentId;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final category = Category(
          id: widget.category?.id,
          name: _name,
          code: _code,
          departmentId: _selectedDepartmentId!,
        );
        int? newId;
        if (widget.category == null) {
          newId = await ref
              .read(categoryListProvider.notifier)
              .addCategory(category);
        } else {
          await ref
              .read(categoryListProvider.notifier)
              .updateCategory(category);
        }
        if (mounted) {
          Navigator.of(context).pop(newId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Categoría guardada correctamente'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar la categoría: $e'),
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
    final departmentsAsync = ref.watch(departmentListProvider);
    var title = widget.category == null
        ? 'Nueva Categoria'
        : 'Editar Categoria';
    var submitText = widget.category == null ? 'Crear' : 'Actualizar';

    var formContent = Column(
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
        const SizedBox(height: UIConstants.spacingLarge),
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
          error: (err, stack) => Text('Error al cargar departamentos: $err'),
        ),
      ],
    );

    if (widget.isDialog) {
      return SimpleDialogForm(
        title: title,
        isLoading: _isLoading,
        onSubmit: _submit,
        submitButtonText: submitText,
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
