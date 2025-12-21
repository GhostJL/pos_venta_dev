import 'package:flutter/material.dart';

class QuantityCostSection extends StatelessWidget {
  final TextEditingController quantityController;
  final TextEditingController unitCostController;

  const QuantityCostSection({
    super.key,
    required this.quantityController,
    required this.unitCostController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cantidad y Precio',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: quantityController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Cantidad *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Inválido';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Debe ser mayor a 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: unitCostController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Costo Unitario *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Inválido';
                  }
                  if (double.parse(value) < 0) {
                    return 'No puede ser negativo';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
