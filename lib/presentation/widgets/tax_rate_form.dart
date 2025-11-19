import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/app/theme.dart';

class TaxRateForm extends ConsumerStatefulWidget {
  final TaxRate? taxRate;

  const TaxRateForm({super.key, this.taxRate});

  @override
  ConsumerState<TaxRateForm> createState() => _TaxRateFormState();
}

class _TaxRateFormState extends ConsumerState<TaxRateForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  late double _rate;
  late bool _isDefault;
  late bool _isOptional;

  @override
  void initState() {
    super.initState();
    _name = widget.taxRate?.name ?? '';
    _code = widget.taxRate?.code ?? '';
    _rate = widget.taxRate?.rate ?? 0.0;
    _isDefault = widget.taxRate?.isDefault ?? false;
    _isOptional = widget.taxRate?.isOptional ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditable = widget.taxRate?.isEditable ?? true;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.taxRate == null
            ? 'Nueva Tasa de Impuesto'
            : isEditable
            ? 'Editar Tasa de Impuesto'
            : 'Detalle de Impuesto',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                enabled: isEditable,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _code,
                enabled: isEditable,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  prefixIcon: Icon(Icons.qr_code_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un código';
                  }
                  return null;
                },
                onSaved: (value) => _code = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _rate.toString(),
                enabled: isEditable,
                decoration: const InputDecoration(
                  labelText: 'Tasa (%)',
                  prefixIcon: Icon(Icons.percent_rounded),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Por favor ingrese una tasa válida';
                  }
                  return null;
                },
                onSaved: (value) => _rate = double.parse(value!),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('¿Es predeterminada?'),
                value: _isDefault,
                activeColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onChanged: isEditable
                    ? (value) {
                        setState(() {
                          _isDefault = value!;
                          if (_isDefault) _isOptional = false;
                        });
                      }
                    : null,
              ),
              CheckboxListTile(
                title: const Text('¿Es opcional?'),
                value: _isOptional,
                activeColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onChanged: isEditable
                    ? (value) {
                        setState(() {
                          _isOptional = value!;
                          if (_isOptional) _isDefault = false;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(isEditable ? 'Cancelar' : 'Cerrar'),
        ),
        if (isEditable)
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Guardar'),
          ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check for duplicates
      final taxRates = ref.read(taxRateListProvider).value ?? [];
      final isDuplicateName = taxRates.any(
        (t) =>
            t.name.toLowerCase() == _name.toLowerCase() &&
            t.id != widget.taxRate?.id,
      );
      final isDuplicateCode = taxRates.any(
        (t) =>
            t.code.toLowerCase() == _code.toLowerCase() &&
            t.id != widget.taxRate?.id,
      );

      if (isDuplicateName) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe un impuesto con este nombre.'),
          ),
        );
        return;
      }

      if (isDuplicateCode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe un impuesto con este código.'),
          ),
        );
        return;
      }

      final newTaxRate = TaxRate(
        id: widget.taxRate?.id,
        name: _name,
        code: _code,
        rate: _rate,
        isDefault: _isDefault,
        isEditable:
            widget.taxRate?.isEditable ??
            true, // Default to editable for new ones
        isOptional: _isOptional,
      );
      if (widget.taxRate == null) {
        ref.read(taxRateListProvider.notifier).addTaxRate(newTaxRate);
      } else {
        ref.read(taxRateListProvider.notifier).updateTaxRate(newTaxRate);
      }
      Navigator.of(context).pop();
    }
  }
}
