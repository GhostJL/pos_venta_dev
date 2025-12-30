import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/presentation/widgets/common/selection_sheet.dart';
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
        // Generar código automático si es nuevo o está vacío
        if (_code.isEmpty) {
          final prefix = _name.length >= 3
              ? _name.substring(0, 3).toUpperCase()
              : _name.toUpperCase().padRight(3, 'X');
          final random = DateTime.now().millisecondsSinceEpoch
              .toString()
              .substring(9);
          _code = '$prefix-$random';
        }

        final category = Category(
          id: widget.category?.id,
          name: _name,
          code: _code,
          departmentId:
              _selectedDepartmentId!, // Strict (! safe due to validator)
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

  Future<void> _showSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) labelBuilder,
    T? selectedItem,
    required ValueChanged<T?> onSelected,
  }) async {
    final result = await showModalBottomSheet<SelectionSheetResult<T>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SelectionSheet<T>(
        title: title,
        items: items,
        itemLabelBuilder: labelBuilder,
        selectedItem: selectedItem,
        areEqual: (a, b) => labelBuilder(a) == labelBuilder(b),
      ),
    );

    if (result != null) {
      if (result.isCleared) {
        onSelected(null);
      } else if (result.value != null) {
        onSelected(result.value);
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
          textInputAction: TextInputAction.next,
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

        departmentsAsync.when(
          data: (departments) {
            final selectedDept = departments.cast<Department?>().firstWhere(
              (d) => d?.id == _selectedDepartmentId,
              orElse: () => null,
            );

            return SelectionField(
              label: 'Departamento',
              placeholder: 'Seleccionar departamento', // Explicit placeholder
              value: selectedDept?.name,
              prefixIcon: Icons.business_rounded,
              onTap: () => _showSelectionSheet<Department>(
                context: context,
                title: 'Seleccionar Departamento',
                items: departments,
                labelBuilder: (d) => d.name,
                selectedItem: selectedDept,
                onSelected: (d) =>
                    setState(() => _selectedDepartmentId = d?.id),
              ),
              onClear: () => setState(
                () => _selectedDepartmentId = null,
              ), // Allow clearing
              validator: (value) => _selectedDepartmentId == null
                  ? 'Por favor, selecciona un departamento'
                  : null, // Restore validation
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
