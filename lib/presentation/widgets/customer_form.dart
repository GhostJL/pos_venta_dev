import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/providers/providers.dart';

class CustomerForm extends ConsumerStatefulWidget {
  final Customer? customer;

  const CustomerForm({super.key, this.customer});

  @override
  CustomerFormState createState() => CustomerFormState();
}

class CustomerFormState extends ConsumerState<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  String _code = '';
  late String _firstName;
  late String _lastName;
  String? _phone;
  String? _email;
  String? _address;
  String? _taxId;
  String? _businessName;

  @override
  void initState() {
    super.initState();
    if (widget.customer == null) {
      _loadNextCode();
    } else {
      _code = widget.customer!.code;
    }
    _firstName = widget.customer?.firstName ?? '';
    _lastName = widget.customer?.lastName ?? '';
    _phone = widget.customer?.phone;
    _email = widget.customer?.email;
    _address = widget.customer?.address;
    _taxId = widget.customer?.taxId;
    _businessName = widget.customer?.businessName;
  }

  Future<void> _loadNextCode() async {
    final nextCode = await ref
        .read(generateNextCustomerCodeUseCaseProvider)
        .call();
    setState(() {
      _code = nextCode;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final customer = Customer(
        id: widget.customer?.id,
        code: _code,
        firstName: _firstName,
        lastName: _lastName,
        phone: _phone,
        email: _email,
        address: _address,
        taxId: _taxId,
        businessName: _businessName,
        isActive: widget.customer?.isActive ?? true,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (widget.customer == null) {
        ref.read(customerProvider.notifier).addCustomer(customer);
      } else {
        ref.read(customerProvider.notifier).updateCustomer(customer);
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
        title: Text(
          widget.customer == null ? 'Nuevo Cliente' : 'Editar Cliente',
        ),
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
                controller: TextEditingController(text: _code),
                readOnly:
                    widget.customer == null, // Read-only for new customers
                enabled:
                    widget.customer !=
                    null, // Editable only for existing? Or always read-only?
                // Usually code is unique and shouldn't change easily, but let's allow edit if existing,
                // or maybe just read-only always if auto-generated.
                // The user asked for auto-increment to avoid errors, implying they shouldn't touch it.
                // I'll make it read-only always for now, or maybe just for new.
                // If I make it read-only, I need a controller to update the text when state changes.
                decoration: const InputDecoration(
                  labelText: 'Código (Auto-generado)',
                  prefixIcon: Icon(Icons.qr_code),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Generando código...';
                  }
                  return null;
                },
                onSaved: (value) => _code = value!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _firstName,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                      onSaved: (value) => _firstName = value!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _lastName,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                      onSaved: (value) => _lastName = value!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                onSaved: (value) => _phone = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                onSaved: (value) => _email = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                onSaved: (value) => _address = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _taxId,
                decoration: const InputDecoration(
                  labelText: 'RFC / Tax ID',
                  prefixIcon: Icon(Icons.receipt_long),
                ),
                onSaved: (value) => _taxId = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _businessName,
                decoration: const InputDecoration(
                  labelText: 'Razón Social (Opcional)',
                  prefixIcon: Icon(Icons.business),
                ),
                onSaved: (value) => _businessName = value,
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
          child: Text(
            widget.customer == null ? 'Crear Cliente' : 'Actualizar Cliente',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
