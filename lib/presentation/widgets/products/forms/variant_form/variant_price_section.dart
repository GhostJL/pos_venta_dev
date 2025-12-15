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
        _buildSectionTitle(context, 'Precios'),
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
            if (state.type != VariantType.purchase) ...[
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
          ],
        ),
        if (state.type != VariantType.purchase) ...[
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
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    // Mapa de iconos para un toque visual (opcional)
    final Map<String, IconData> sectionIcons = {'Precios': Icons.attach_money};

    final icon = sectionIcons[title];

    return Padding(
      // Añadimos padding superior para asegurarnos de que el título esté bien separado de la sección anterior
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary, // Color de acento
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 18, // Ligeramente más grande para jerarquía
              fontWeight:
                  FontWeight.w700, // Más fuerte, pero sin ser negrita pura
              color: Theme.of(
                context,
              ).colorScheme.primary, // Color principal de texto
              letterSpacing: 0.5, // Un toque moderno
            ),
          ),
        ],
      ),
    );
  }
}
