import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/entities/brand.dart';
import 'package:myapp/presentation/providers/brand_providers.dart';

class BrandForm extends ConsumerStatefulWidget {
  final Brand? brand;

  const BrandForm({super.key, this.brand});

  @override
  BrandFormState createState() => BrandFormState();
}

class BrandFormState extends ConsumerState<BrandForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.brand?.name ?? '');
    _codeController = TextEditingController(text: widget.brand?.code ?? '');
    _isActive = widget.brand?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.brand == null ? 'Nueva Marca' : 'Editar Marca'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
              validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Código',
              ),
              validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Activo'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), // Cancelar
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final brand = Brand(
                id: widget.brand?.id,
                name: _nameController.text,
                code: _codeController.text,
                isActive: _isActive,
              );
              if (widget.brand == null) {
                ref.read(brandListProvider.notifier).createBrand(brand);
              } else {
                ref.read(brandListProvider.notifier).updateBrand(brand);
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Guardar'), // Guardar
        ),
      ],
    );
  }
}
