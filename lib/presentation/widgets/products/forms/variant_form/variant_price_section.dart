import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantPriceSection extends ConsumerWidget {
  final ProductVariant? variant;

  const VariantPriceSection({super.key, this.variant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(variantFormProvider(variant));
    final notifier = ref.read(variantFormProvider(variant).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Precios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: state.cost,
                decoration: const InputDecoration(
                  labelText: 'Costo',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: notifier.updateCost,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Requerido';
                  final number = double.tryParse(value!);
                  if (number == null || number < 0) {
                    return 'Debe ser mayor o igual a 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: state.price,
                decoration: const InputDecoration(
                  labelText: 'Precio de Venta',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.sell),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: notifier.updatePrice,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Requerido';
                  final number = double.tryParse(value!);
                  if (number == null || number <= 0) {
                    return 'Debe ser mayor a 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.wholesalePrice,
          decoration: const InputDecoration(
            labelText: 'Precio Mayorista (Opcional)',
            prefixText: '\$ ',
            prefixIcon: Icon(Icons.storefront),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: notifier.updateWholesalePrice,
          validator: (value) {
            if (value?.isNotEmpty ?? false) {
              final number = double.tryParse(value!);
              if (number == null || number < 0) {
                return 'Debe ser mayor o igual a 0';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
