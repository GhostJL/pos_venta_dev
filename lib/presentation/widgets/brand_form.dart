import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';

class BrandForm extends ConsumerStatefulWidget {
  final Brand? brand;

  const BrandForm({super.key, this.brand});

  @override
  BrandFormState createState() => BrandFormState();
}

class BrandFormState extends ConsumerState<BrandForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;

  @override
  void initState() {
    super.initState();
    _name = widget.brand?.name ?? '';
    _code = widget.brand?.code ?? '';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final brand = Brand(id: widget.brand?.id, name: _name, code: _code);
      if (widget.brand == null) {
        ref.read(brandListProvider.notifier).addBrand(brand);
      } else {
        ref.read(brandListProvider.notifier).updateBrand(brand);
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
        title: Text(widget.brand == null ? 'Nueva Marca' : 'Editar Marca'),
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
                  labelText: 'Nombre de la Marca',
                  prefixIcon: Icon(Icons.branding_watermark_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre de marca';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _code,
                decoration: const InputDecoration(
                  labelText: 'Código de la Marca',
                  prefixIcon: Icon(Icons.qr_code_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un código de marca';
                  }
                  return null;
                },
                onSaved: (value) => _code = value!,
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
            elevation: 0,
          ),
          child: Text(
            widget.brand == null ? 'Crear Marca' : 'Actualizar Marca',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
