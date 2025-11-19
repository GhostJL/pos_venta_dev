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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.taxRate == null
            ? 'Nueva Tasa de Impuesto'
            : 'Editar Tasa de Impuesto',
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
                onChanged: (value) {
                  setState(() {
                    _isDefault = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
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
      final newTaxRate = TaxRate(
        id: widget.taxRate?.id,
        name: _name,
        code: _code,
        rate: _rate,
        isDefault: _isDefault,
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
