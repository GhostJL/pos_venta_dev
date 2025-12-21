import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/widgets/common/generic_form_scaffold.dart';
import 'package:posventa/presentation/widgets/common/simple_dialog_form.dart';

class BrandForm extends ConsumerStatefulWidget {
  final Brand? brand;
  final bool isDialog;

  const BrandForm({super.key, this.brand, this.isDialog = false});

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
        // Generar código automático si es nuevo o está vacío
        if (_code.isEmpty) {
          final prefix = _name.length >= 3
              ? _name.substring(0, 3).toUpperCase()
              : _name.toUpperCase().padRight(3, 'X');
          final random = DateTime.now().millisecondsSinceEpoch
              .toString()
              .substring(9);
          _code = '$prefix-$random';
        }

        final brand = Brand(id: widget.brand?.id, name: _name, code: _code);
        Brand? newBrand;
        if (widget.brand == null) {
          newBrand = await ref.read(brandListProvider.notifier).addBrand(brand);
        } else {
          await ref.read(brandListProvider.notifier).updateBrand(brand);
        }
        if (mounted) {
          Navigator.of(context).pop(newBrand);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Marca guardada correctamente'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar la marca: $e'),
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
    var title = widget.brand == null ? 'Nueva Marca' : 'Editar Marca';
    var submitText = widget.brand == null ? 'Crear' : 'Actualizar';

    var formContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: _name,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
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
      ],
    );

    if (widget.isDialog) {
      return SimpleDialogForm(
        title: title,
        isLoading: _isLoading,
        onSubmit: _submit,
        submitButtonText: submitText,
        formKey: _formKey,
        child: formContent,
      );
    }

    return GenericFormScaffold(
      title: title,
      isLoading: _isLoading,
      onSubmit: _submit,
      submitButtonText: submitText,
      formKey: _formKey,
      child: formContent,
    );
  }
}
