
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';

class TaxRatePage extends ConsumerWidget {
  const TaxRatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxRates = ref.watch(taxRatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Tasas de Impuestos')),
      body: taxRates.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final taxRate = data[index];
            return ListTile(
              leading: !taxRate.isEditable ? const Icon(Icons.lock, color: Colors.grey) : null,
              title: Text('${taxRate.name} (${taxRate.code})'),
              subtitle: Text('Tasa: ${taxRate.rate * 100}%'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (taxRate.isDefault)
                    const Chip(
                      label: Text('Default'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  IconButton(
                    icon: Icon(taxRate.isEditable ? Icons.edit : Icons.visibility),
                    tooltip: taxRate.isEditable ? 'Editar' : 'Ver',
                    onPressed: () => _showTaxRateDialog(context, ref, taxRate),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: taxRate.isEditable
                        ? () => _deleteTaxRate(context, ref, taxRate)
                        : () => _showCannotPerformOperationDialog(context, 'eliminar'),
                  ),
                  if (!taxRate.isDefault)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'setDefault') {
                          ref
                              .read(taxRatesProvider.notifier)
                              .setDefaultTaxRate(taxRate.id!);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'setDefault',
                              child: Text('Establecer como default'),
                            ),
                          ],
                    ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')), // Simplified error display
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaxRateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTaxRateDialog(
    BuildContext context,
    WidgetRef ref, [
    TaxRate? taxRate,
  ]) {
    final isEditing = taxRate != null;
    final isEditable = taxRate?.isEditable ?? true; // New taxes are editable

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: taxRate?.name);
    final codeController = TextEditingController(text: taxRate?.code);
    final rateController = TextEditingController(
      text: taxRate != null ? (taxRate.rate * 100).toString() : '',
    );
    var isOptional = taxRate?.isOptional ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          !isEditing
              ? 'Añadir Tasa de Impuesto'
              : isEditable 
                ? 'Editar Tasa de Impuesto'
                : 'Ver Tasa de Impuesto',
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                readOnly: !isEditable,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingrese un nombre' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: codeController,
                readOnly: !isEditable,
                decoration: const InputDecoration(labelText: 'Código'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingrese un código' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: rateController,
                readOnly: !isEditable,
                decoration: const InputDecoration(labelText: 'Tasa (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una tasa';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              if (isEditable)
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return CheckboxListTile(
                      title: const Text("Opcional"),
                      value: isOptional,
                      onChanged: (newValue) {
                        setState(() {
                          isOptional = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          if (isEditable)
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newTaxRate = TaxRate(
                    id: taxRate?.id,
                    name: nameController.text,
                    code: codeController.text,
                    rate: double.parse(rateController.text) / 100,
                    isDefault: taxRate?.isDefault ?? false,
                    isEditable: true,
                    isOptional: isOptional,
                  );

                  try {
                    if (taxRate == null) {
                      await ref.read(taxRatesProvider.notifier).addTaxRate(newTaxRate);
                    } else {
                      await ref.read(taxRatesProvider.notifier).updateTaxRate(newTaxRate);
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: const Text('Guardar'),
            ),
        ],
      ),
    );
  }

  void _deleteTaxRate(BuildContext context, WidgetRef ref, TaxRate taxRate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tasa de Impuesto'),
        content: Text('¿Está seguro que desea eliminar ${taxRate.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(taxRatesProvider.notifier).deleteTaxRate(taxRate.id!);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCannotPerformOperationDialog(BuildContext context, String operation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Operación no permitida'),
        content: Text('Esta tasa de impuesto es predefinida y no se puede $operation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
