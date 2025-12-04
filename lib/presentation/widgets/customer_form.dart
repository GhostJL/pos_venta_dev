import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/widgets/common/generic_form_scaffold.dart';

import 'package:posventa/core/constants/ui_constants.dart';

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
  bool _isLoading = false;

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
    if (mounted) {
      setState(() {
        _code = nextCode;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
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
          await ref.read(customerProvider.notifier).addCustomer(customer);
        } else {
          await ref.read(customerProvider.notifier).updateCustomer(customer);
        }

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cliente guardado correctamente'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar el cliente: $e'),
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
      title: widget.customer == null ? 'Nuevo Cliente' : 'Editar Cliente',
      isLoading: _isLoading,
      onSubmit: _submit,
      submitButtonText: widget.customer == null
          ? 'Crear Cliente'
          : 'Actualizar Cliente',
      formKey: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: TextEditingController(text: _code),
            readOnly: true,
            enabled: false,
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
          ),
          const SizedBox(height: UIConstants.spacingMedium),
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
                      return 'El nombre es requerido';
                    }
                    if (value.length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
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
                      return 'El apellido es requerido';
                    }
                    if (value.length < 2) {
                      return 'El apellido debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                  onSaved: (value) => _lastName = value!,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          TextFormField(
            initialValue: _phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            onSaved: (value) => _phone = value,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          TextFormField(
            initialValue: _email,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Por favor, introduce un email válido';
                }
              }
              return null;
            },
            onSaved: (value) => _email = value,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          TextFormField(
            initialValue: _address,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 2,
            onSaved: (value) => _address = value,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          TextFormField(
            initialValue: _taxId,
            decoration: const InputDecoration(
              labelText: 'RFC / Tax ID',
              prefixIcon: Icon(Icons.receipt_long),
            ),
            onSaved: (value) => _taxId = value,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
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
    );
  }
}
