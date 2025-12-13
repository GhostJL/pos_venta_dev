import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';

/// Widget for product pricing section
class ProductPricingSection extends ConsumerWidget {
  final Product? product;
  final TextEditingController costPriceController;
  final TextEditingController salePriceController;
  final TextEditingController wholesalePriceController;
  final bool showPrices;

  const ProductPricingSection({
    super.key,
    required this.product,
    required this.costPriceController,
    required this.salePriceController,
    required this.wholesalePriceController,
    this.showPrices = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productFormProvider(product);
    final unitsAsync = ref.watch(unitListProvider);

    final selectedUnitId = ref.watch(provider.select((s) => s.unitId));
    final isSoldByWeight = ref.watch(provider.select((s) => s.isSoldByWeight));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        unitsAsync.when(
          data: (units) => DropdownButtonFormField<int>(
            initialValue: selectedUnitId,
            decoration: InputDecoration(
              labelText: 'Unidad de Medida',
              prefixIcon: Icon(Icons.scale_rounded),
            ),
            items: units
                .map(
                  (unit) =>
                      DropdownMenuItem(value: unit.id, child: Text(unit.name)),
                )
                .toList(),
            onChanged: (value) => ref.read(provider.notifier).setUnit(value),
            validator: (value) => value == null ? 'Requerido' : null,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Venta por Peso'),
          value: isSoldByWeight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          onChanged: (value) =>
              ref.read(provider.notifier).setSoldByWeight(value),
        ),
        if (showPrices) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: costPriceController,
                  decoration: InputDecoration(
                    labelText: 'Costo',
                    prefixText: '\$ ',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: salePriceController,
                  decoration: InputDecoration(
                    labelText: 'Venta',
                    prefixText: '\$ ',
                    prefixIcon: Icon(Icons.sell_rounded),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: wholesalePriceController,
            decoration: InputDecoration(
              labelText: 'Precio Mayorista (Opcional)',
              prefixText: '\$ ',
              prefixIcon: Icon(Icons.storefront_rounded),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ],
    );
  }
}
