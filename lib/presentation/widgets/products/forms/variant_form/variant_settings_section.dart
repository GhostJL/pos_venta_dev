import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantSettingsSection extends ConsumerWidget {
  final ProductVariant? variant;

  const VariantSettingsSection({super.key, this.variant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(variantFormProvider(variant));
    final notifier = ref.read(variantFormProvider(variant).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Configuración'),
        const SizedBox(height: 8),
        if (state.type == VariantType.sales) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.stockMin,
                  decoration: const InputDecoration(
                    labelText: 'Stock Mínimo',
                    prefixIcon: Icon(Icons.arrow_downward),
                    helperText: 'Alerta cuando baje de',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: notifier.updateStockMin,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final n = double.tryParse(value);
                    if (n == null || n < 0) return 'Inválido';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: state.stockMax,
                  decoration: const InputDecoration(
                    labelText: 'Stock Máximo',
                    prefixIcon: Icon(Icons.arrow_upward),
                    helperText: 'Meta de inventario',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: notifier.updateStockMax,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final n = double.tryParse(value);
                    if (n == null || n < 0) return 'Inválido';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    // Mapa de iconos para un toque visual (opcional)
    final Map<String, IconData> sectionIcons = {
      'Configuración': Icons.settings,
    };

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
