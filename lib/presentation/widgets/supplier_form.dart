import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
        ref.read(supplierListProvider.notifier).addSupplier(supplier);
      } else {
        ref.read(supplierListProvider.notifier).updateSupplier(supplier);
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
        title: Text(widget.supplier == null ? 'Nuevo Proveedor' : 'Editar Proveedor'),
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
                  labelText: 'Nombre del Proveedor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre de proveedor';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _code,
                decoration: const InputDecoration(
                  labelText: 'Código del Proveedor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un código de proveedor';
                  }
                  return null;
                },
                onSaved: (value) => _code = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _contactName,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Contacto',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _contactName = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _phone = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _email = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _address = value,
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
          child: Text(widget.supplier == null ? 'Crear' : 'Actualizar'),
        ),
      ),
    );
  }
}
