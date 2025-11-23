import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/widgets/common/generic_form_scaffold.dart';
import 'package:posventa/core/theme/theme.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.brand?.name ?? '';
    _code = widget.brand?.code ?? '';
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final brand = Brand(id: widget.brand?.id, name: _name, code: _code);
        if (widget.brand == null) {
          await ref.read(brandListProvider.notifier).addBrand(brand);
        } else {
          await ref.read(brandListProvider.notifier).updateBrand(brand);
        }
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Marca guardada correctamente'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar la marca: $e'),
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
      title: widget.brand == null ? 'Nueva Marca' : 'Editar Marca',
      isLoading: _isLoading,
      onSubmit: _submit,
      submitButtonText: widget.brand == null
          ? 'Crear Marca'
          : 'Actualizar Marca',
      formKey: _formKey,
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
    );
  }
}
