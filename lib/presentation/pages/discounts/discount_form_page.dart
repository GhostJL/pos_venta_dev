import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/discount.dart';
import 'package:posventa/presentation/providers/discount_provider.dart';

class DiscountFormPage extends ConsumerStatefulWidget {
  final Discount? discount;

  const DiscountFormPage({super.key, this.discount});

  @override
  ConsumerState<DiscountFormPage> createState() => _DiscountFormPageState();
}

class _DiscountFormPageState extends ConsumerState<DiscountFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  DiscountType _type = DiscountType.percentage;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.discount?.name ?? '');

    // Initial value formatting
    String initialValue = '';
    if (widget.discount != null) {
      if (widget.discount!.type == DiscountType.percentage) {
        initialValue = (widget.discount!.value / 100)
            .toString(); // 1000 -> 10.0
      } else {
        initialValue = (widget.discount!.value / 100)
            .toString(); // 1000 -> 10.00
      }
    }

    _valueController = TextEditingController(text: initialValue);
    _type = widget.discount?.type ?? DiscountType.percentage;
    _startDate = widget.discount?.startDate;
    _endDate = widget.discount?.endDate;
    _isActive = widget.discount?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final valueDouble = double.tryParse(_valueController.text) ?? 0.0;

    int valueInt; // Store as integer
    if (_type == DiscountType.percentage) {
      valueInt = (valueDouble * 100)
          .toInt(); // 10% -> 10.0 -> 1000 (basis points)
    } else {
      valueInt = (valueDouble * 100).toInt(); // $10 -> 1000 cents
    }

    final newDiscount = Discount(
      id: widget.discount?.id ?? 0, // 0 for new? or ignore id on create
      name: name,
      type: _type,
      value: valueInt,
      startDate: _startDate,
      endDate: _endDate,
      isActive: _isActive,
      createdAt: widget.discount?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.discount == null) {
        await ref
            .read(discountListProvider.notifier)
            .createDiscount(newDiscount);
      } else {
        await ref
            .read(discountListProvider.notifier)
            .updateDiscount(newDiscount);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.discount == null ? 'Nuevo Descuento' : 'Editar Descuento',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Descuento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DiscountType>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: DiscountType.percentage,
                          child: Text('Porcentaje (%)'),
                        ),
                        DropdownMenuItem(
                          value: DiscountType.amount,
                          child: Text('Monto Fijo (\$'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _type = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _valueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        border: const OutlineInputBorder(),
                        suffixText: _type == DiscountType.percentage ? '%' : '',
                        prefixText: _type == DiscountType.amount ? '\$' : '',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        final num = double.tryParse(v);
                        if (num == null || num < 0) return 'Inválido';
                        if (_type == DiscountType.percentage && num > 100) {
                          return 'Máximo 100%';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Activo'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),

              const Divider(),
              const Text(
                'Vigencia (Opcional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _startDate == null
                            ? 'Inicio'
                            : DateFormat('dd/MM/yyyy').format(_startDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _endDate == null
                            ? 'Fin'
                            : DateFormat('dd/MM/yyyy').format(_endDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              _endDate ?? (_startDate ?? DateTime.now()),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _endDate = picked);
                      },
                    ),
                  ),
                ],
              ),
              if (_startDate != null || _endDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(
                    onPressed: () => setState(() {
                      _startDate = null;
                      _endDate = null;
                    }),
                    child: const Text('Borrar Vigencia'),
                  ),
                ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Guardar Descuento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
