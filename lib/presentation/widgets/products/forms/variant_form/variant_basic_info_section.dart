import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantBasicInfoSection extends ConsumerWidget {
  final ProductVariant? variant;
  final List<ProductVariant>? availableVariants;

  const VariantBasicInfoSection({
    super.key,
    this.variant,
    this.availableVariants,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(variantFormProvider(variant));
    final notifier = ref.read(variantFormProvider(variant).notifier);

    // Filter available variants for linking:
    // 1. Must be Sales type (optional, but logical for a Purchase variant to link to a Sales one)
    // 2. Exclude self
    final linkableVariants =
        availableVariants?.where((v) {
          if (v.id != null && v.id == variant?.id) return false;
          // Temporary variants might not have ID, check name if needed, but ID is safer.
          // If creating new, variant.id is null.
          // If v is in availableVariants, it might include the one we are editing if passed from parent?
          // Usually passing "other" variants is better.
          return v.type == VariantType.sales;
        }).toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Información Básica'),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.name,
          decoration: const InputDecoration(
            labelText: 'Nombre de la Variante',
            helperText: 'Ej: Caja con 12, Paquete de 6, etc.',
            prefixIcon: Icon(Icons.label),
          ),
          onChanged: notifier.updateName,
          validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                initialValue: state.quantity,
                decoration: const InputDecoration(
                  labelText: 'Cantidad / Factor',
                  helperText: 'Unidades base',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: notifier.updateQuantity,
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
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<VariantType>(
                initialValue: state.type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  helperText: 'Uso de la variante',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(
                    value: VariantType.sales,
                    child: Text('Venta'),
                  ),
                  DropdownMenuItem(
                    value: VariantType.purchase,
                    child: Text('Compra'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    notifier.updateType(value);
                  }
                },
              ),
            ),
          ],
        ),
        if (state.type == VariantType.purchase) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: state.linkedVariantId,
            decoration: const InputDecoration(
              labelText: 'Enlace a Variante de Venta',
              helperText: 'Al comprar esto, se sumará stock a...',
              prefixIcon: Icon(Icons.link),
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('Sin enlace (Abastece al producto base)'),
              ),
              ...linkableVariants.map((v) {
                return DropdownMenuItem<int>(
                  value: v.id,
                  child: Text(
                    '${v.variantName} (x${v.quantity})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            onChanged: notifier.updateLinkedVariantId,
            isExpanded: true,
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    // Mapa de iconos para un toque visual (opcional)
    final Map<String, IconData> sectionIcons = {
      'Información Básica': Icons.info_outline_rounded,
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
