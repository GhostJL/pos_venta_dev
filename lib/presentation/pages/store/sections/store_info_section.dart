import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/store.dart';
import 'package:posventa/presentation/providers/store_provider.dart';

class StoreInfoSection extends ConsumerStatefulWidget {
  final Store store;
  const StoreInfoSection({super.key, required this.store});

  @override
  ConsumerState<StoreInfoSection> createState() => _StoreInfoSectionState();
}

class _StoreInfoSectionState extends ConsumerState<StoreInfoSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _businessNameController;
  late TextEditingController _taxIdController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.store.name);
    _businessNameController = TextEditingController(
      text: widget.store.businessName,
    );
    _taxIdController = TextEditingController(text: widget.store.taxId);
    _addressController = TextEditingController(text: widget.store.address);
    _phoneController = TextEditingController(text: widget.store.phone);
    _emailController = TextEditingController(text: widget.store.email);
    _websiteController = TextEditingController(text: widget.store.website);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final updatedStore = widget.store.copyWith(
        name: _nameController.text,
        businessName: _businessNameController.text,
        taxId: _taxIdController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text,
        updatedAt: DateTime.now(),
      );
      ref.read(storeProvider.notifier).updateStore(updatedStore);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información actualizada correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Tienda',
                prefixIcon: Icon(Icons.store),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Razón Social',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxIdController,
              decoration: const InputDecoration(
                labelText: 'RFC / Tax ID',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Sitio Web',
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
