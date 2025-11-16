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
        contactPerson: _contactPersonController.text.isNotEmpty ? _contactPersonController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        taxId: _taxIdController.text.isNotEmpty ? _taxIdController.text : null,
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
                decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Código', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'El código es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactPersonController,
                decoration: const InputDecoration(labelText: 'Persona de Contacto', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Introduce un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taxIdController,
                decoration: const InputDecoration(labelText: 'ID Fiscal (RFC/RUT)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditDaysController,
                decoration: const InputDecoration(labelText: 'Días de Crédito', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduce los días de crédito';
                  if (int.tryParse(value) == null) return 'Introduce un número válido';
                  return null;
                },
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
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
