import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _name = widget.taxRate?.name ?? '';
    _code = widget.taxRate?.code ?? '';
    _rate = widget.taxRate?.rate ?? 0.0;
    _isDefault = widget.taxRate?.isDefault ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.taxRate == null ? 'Nueva Tasa de Impuesto' : 'Editar Tasa de Impuesto'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              initialValue: _code,
              decoration: const InputDecoration(labelText: 'Código'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un código';
                }
                return null;
              },
              onSaved: (value) => _code = value!,
            ),
            TextFormField(
              initialValue: _rate.toString(),
              decoration: const InputDecoration(labelText: 'Tasa (%)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || double.tryParse(value) == null) {
                  return 'Por favor ingrese una tasa válida';
                }
                return null;
              },
              onSaved: (value) => _rate = double.parse(value!),
            ),
            CheckboxListTile(
              title: const Text('¿Es predeterminada?'),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newTaxRate = TaxRate(
        id: widget.taxRate?.id,
        name: _name,
        code: _code,
        rate: _rate,
        isDefault: _isDefault,
      );
      if (widget.taxRate == null) {
        ref.read(taxRatesProvider.notifier).addTaxRate(newTaxRate);
      } else {
        ref.read(taxRatesProvider.notifier).updateTaxRate(newTaxRate);
      }
      Navigator.of(context).pop();
    }
  }
}
