import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/providers/providers.dart';

/// Widget for product pricing section
class ProductPricingSection extends ConsumerWidget {
  final int? selectedUnitId;
  final ValueChanged<int?> onUnitChanged;
  final TextEditingController costPriceController;
  final TextEditingController salePriceController;
  final TextEditingController wholesalePriceController;
  final bool isSoldByWeight;
  final ValueChanged<bool> onSoldByWeightChanged;

  const ProductPricingSection({
    super.key,
    required this.selectedUnitId,
    required this.onUnitChanged,
    required this.costPriceController,
    required this.salePriceController,
    required this.wholesalePriceController,
    required this.isSoldByWeight,
    required this.onSoldByWeightChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        unitsAsync.when(
          data: (units) => DropdownButtonFormField<int>(
            value: selectedUnitId,
            decoration: const InputDecoration(
              labelText: 'Unidad de Medida',
              prefixIcon: Icon(Icons.scale_rounded),
            ),
            items: units
                .map(
                  (unit) =>
                      DropdownMenuItem(value: unit.id, child: Text(unit.name)),
                )
                .toList(),
            onChanged: onUnitChanged,
            validator: (value) => value == null ? 'Requerido' : null,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Venta por Peso'),
          value: isSoldByWeight,
          activeColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.borders),
          ),
          onChanged: onSoldByWeightChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: costPriceController,
                decoration: const InputDecoration(
                  labelText: 'Costo',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Requerido' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: salePriceController,
                decoration: const InputDecoration(
                  labelText: 'Venta',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.sell_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Requerido' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: wholesalePriceController,
          decoration: const InputDecoration(
            labelText: 'Precio Mayorista (Opcional)',
            prefixText: '\$ ',
            prefixIcon: Icon(Icons.storefront_rounded),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}
