import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/widgets/common/generic_form_scaffold.dart';
import 'package:posventa/core/theme/theme.dart';

class SupplierForm extends ConsumerStatefulWidget {
  final Supplier? supplier;

  const SupplierForm({super.key, this.supplier});

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
        if (widget.supplier == null) {
          await ref.read(supplierListProvider.notifier).addSupplier(supplier);
        } else {
          await ref
              .read(supplierListProvider.notifier)
              .updateSupplier(supplier);
        }
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proveedor guardado correctamente'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar el proveedor: $e'),
              backgroundColor: AppTheme.error,
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
      title: widget.supplier == null ? 'Nuevo Proveedor' : 'Editar Proveedor',
      isLoading: _isLoading,
      onSubmit: _submit,
      submitButtonText: widget.supplier == null
          ? 'Crear Proveedor'
          : 'Actualizar Proveedor',
      formKey: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(
              labelText: 'Nombre del Proveedor',
              prefixIcon: Icon(Icons.business_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, introduce un nombre de proveedor';
              }
              if (value.length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _code,
            decoration: const InputDecoration(
              labelText: 'Código del Proveedor',
              prefixIcon: Icon(Icons.qr_code_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, introduce un código de proveedor';
              }
              return null;
            },
            onSaved: (value) => _code = value!,
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _contactName,
            decoration: const InputDecoration(
              labelText: 'Nombre de Contacto',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            onSaved: (value) => _contactName = value,
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
            onSaved: (value) => _phone = value,
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _email,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!value.contains('@')) {
                  return 'Por favor, introduce un correo electrónico válido';
                }
              }
              return null;
            },
            onSaved: (value) => _email = value,
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _address,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            onSaved: (value) => _address = value,
          ),
        ],
      ),
    );
  }
}
