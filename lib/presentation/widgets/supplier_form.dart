import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/entities/supplier.dart';
import 'package:myapp/presentation/providers/supplier_providers.dart';

class SupplierForm extends ConsumerStatefulWidget {
  final Supplier? supplier;

  const SupplierForm({Key? key, this.supplier}) : super(key: key);

  @override
  _SupplierFormState createState() => _SupplierFormState();
}

class _SupplierFormState extends ConsumerState<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _taxIdController;
  late TextEditingController _creditDaysController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _codeController = TextEditingController(text: widget.supplier?.code ?? '');
    _contactPersonController = TextEditingController(text: widget.supplier?.contactPerson ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _emailController = TextEditingController(text: widget.supplier?.email ?? '');
    _addressController = TextEditingController(text: widget.supplier?.address ?? '');
    _taxIdController = TextEditingController(text: widget.supplier?.taxId ?? '');
    _creditDaysController = TextEditingController(text: widget.supplier?.creditDays.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _creditDaysController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final supplier = Supplier(
        id: widget.supplier?.id,
        name: _nameController.text,
        code: _codeController.text,
        contactPerson: _contactPersonController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        taxId: _taxIdController.text,
        creditDays: int.tryParse(_creditDaysController.text) ?? 0,
        isActive: widget.supplier?.isActive ?? true,
      );

      if (widget.supplier == null) {
        ref.read(supplierListProvider.notifier).addSupplier(supplier);
      } else {
        ref.read(supplierListProvider.notifier).editSupplier(supplier);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.supplier == null ? 'Añadir Proveedor' : 'Editar Proveedor'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Código'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _contactPersonController,
                decoration: const InputDecoration(labelText: 'Persona de Contacto'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextFormField(
                controller: _taxIdController,
                decoration: const InputDecoration(labelText: 'ID Fiscal (RFC)'),
              ),
              TextFormField(
                controller: _creditDaysController,
                decoration: const InputDecoration(labelText: 'Días de Crédito'),
                keyboardType: TextInputType.number,
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
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.supplier == null ? 'Añadir' : 'Guardar'),
        ),
      ],
    );
  }
}
