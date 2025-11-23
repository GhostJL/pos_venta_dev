import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/core/constants/ui_constants.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.taxRate?.name ?? '';
    _code = widget.taxRate?.code ?? '';
    _rate = (widget.taxRate?.rate ?? 0.0) * 100;
    _isDefault = widget.taxRate?.isDefault ?? false;
    _isOptional = widget.taxRate?.isOptional ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isEditable = widget.taxRate?.isEditable ?? true;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusXLarge),
      ),
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                enabled: isEditable && !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  if (value.length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              TextFormField(
                initialValue: _code,
                enabled: isEditable && !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  helperText: 'Ejemplo: IVA_16, ISR_10',
                  prefixIcon: Icon(Icons.qr_code_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un código';
                  }
                  if (value.length < 2) {
                    return 'El código debe tener al menos 2 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _code = value!,
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              TextFormField(
                initialValue: _rate.toString(),
                enabled: isEditable && !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Tasa (%)',
                  helperText: 'Ingrese el porcentaje (ej. 16 para 16%)',
                  prefixIcon: Icon(Icons.percent_rounded),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Por favor ingrese una tasa válida';
                  }
                  final rate = double.parse(value);
                  if (rate < 0 || rate > 100) {
                    return 'La tasa debe estar entre 0 y 100';
                  }
                  return null;
                },
                onSaved: (value) => _rate = double.parse(value!),
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              SwitchListTile(
                title: const Text('¿Es predeterminada?'),
                subtitle: const Text(
                  'Las tasas predeterminadas aparecen de manera opcional y no se pueden modificar o eliminar.',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isDefault,
                activeThumbColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onChanged: (isEditable && !_isLoading)
                    ? (value) {
                        setState(() {
                          _isDefault = value;
                          if (_isDefault) _isOptional = false;
                        });
                      }
                    : null,
              ),
              SwitchListTile(
                title: const Text('¿Es opcional?'),
                subtitle: const Text(
                  'Las tasas opcionales se pueden seleccionar manualmente en cada producto y pueden ser modificadas o eliminadas.',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isOptional,
                activeThumbColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onChanged: (isEditable && !_isLoading)
                    ? (value) {
                        setState(() {
                          _isOptional = value;
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
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(isEditable ? 'Cancelar' : 'Cerrar'),
        ),
        if (isEditable)
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        // Validate using provider methods
        final notifier = ref.read(taxRateListProvider.notifier);

        if (notifier.isDuplicateName(_name, widget.taxRate?.id)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ya existe un impuesto con este nombre.'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
          return;
        }

        if (notifier.isDuplicateCode(_code, widget.taxRate?.id)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ya existe un impuesto con este código.'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
          return;
        }

        if (!_isDefault && !_isOptional) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Debe seleccionar al menos una opción (Predeterminada u Opcional).',
                ),
                backgroundColor: AppTheme.error,
              ),
            );
          }
          return;
        }

        final newTaxRate = TaxRate(
          id: widget.taxRate?.id,
          name: _name,
          code: _code,
          rate: _rate / 100, // Convert percentage to decimal
          isDefault: _isDefault,
          isEditable:
              widget.taxRate?.isEditable ??
              true, // Default to editable for new ones
          isOptional: _isOptional,
        );

        if (widget.taxRate == null) {
          await notifier.addTaxRate(newTaxRate);
        } else {
          await notifier.updateTaxRate(newTaxRate);
        }

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tasa de impuesto guardada correctamente'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar la tasa: $e'),
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
}
