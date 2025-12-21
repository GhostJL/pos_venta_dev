import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/widgets/common/generic_form_scaffold.dart';
import 'package:posventa/presentation/widgets/common/simple_dialog_form.dart';
import 'package:posventa/core/constants/ui_constants.dart';

class SupplierForm extends ConsumerStatefulWidget {
  final Supplier? supplier;
  final bool isDialog;

  const SupplierForm({super.key, this.supplier, this.isDialog = false});

  @override
  SupplierFormState createState() => SupplierFormState();
}

class SupplierFormState extends ConsumerState<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  String? _contactName;
  String? _phone;
  String? _email;
  String? _address;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.supplier?.name ?? '';
    _code = widget.supplier?.code ?? '';
    _contactName = widget.supplier?.contactPerson;
    _phone = widget.supplier?.phone;
    _email = widget.supplier?.email;
    _address = widget.supplier?.address;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final supplier = Supplier(
          id: widget.supplier?.id,
          name: _name,
          code: _code,
          contactPerson: _contactName,
          phone: _phone,
          email: _email,
          address: _address,
        );
        Supplier? newSupplier;
        if (widget.supplier == null) {
          newSupplier = await ref
              .read(supplierListProvider.notifier)
              .addSupplier(supplier);
        } else {
          await ref
              .read(supplierListProvider.notifier)
              .updateSupplier(supplier);
        }
        if (mounted) {
          Navigator.of(context).pop(newSupplier);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Proveedor guardado correctamente'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar el proveedor: $e'),
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
    final theme = Theme.of(context);
    final title = widget.supplier == null
        ? 'Nuevo Proveedor'
        : 'Editar Proveedor';
    final submitText = widget.supplier == null ? 'Crear' : 'Actualizar';

    final formContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(theme, 'Información General', Icons.business_rounded, [
          TextFormField(
            initialValue: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nombre del Proveedor',
              prefixIcon: Icon(Icons.business_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          TextFormField(
            initialValue: _code,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Código del Proveedor',
              prefixIcon: Icon(Icons.qr_code_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El código es requerido';
              }
              return null;
            },
            onSaved: (value) => _code = value!,
          ),
        ]),
        const SizedBox(height: UIConstants.spacingLarge),
        _buildSection(theme, 'Contacto', Icons.contact_phone_outlined, [
          TextFormField(
            initialValue: _contactName,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nombre de Contacto',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            onSaved: (value) => _contactName = value,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          TextFormField(
            initialValue: _phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
            keyboardType: TextInputType.phone,
            onSaved: (value) => _phone = value,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          TextFormField(
            initialValue: _email,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!value.contains('@')) {
                  return 'Email inválido';
                }
              }
              return null;
            },
            onSaved: (value) => _email = value,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          TextFormField(
            initialValue: _address,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Dirección',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            maxLines: 2,
            onSaved: (value) => _address = value,
          ),
        ]),
        const SizedBox(height: UIConstants.spacingXLarge),
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

  Widget _buildSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withAlpha(80),
            ),
          ),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}
