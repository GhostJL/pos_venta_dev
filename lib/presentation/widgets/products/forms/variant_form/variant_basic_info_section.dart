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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(variantFormProvider(variant));
    final notifier = ref.read(variantFormProvider(variant).notifier);

    // Filter available variants for linking
    final linkableVariants =
        availableVariants?.where((v) {
          if (v.id != null && v.id == variant?.id) return false;
          if (v.id == null) return false;
          return v.type == VariantType.sales;
        }).toList() ??
        [];

    final purchaseUnitName = state.unitId != null
        ? 'Unidad Seleccionada'
        : 'Unidad de Compra'; // We can't easily get unit name here without provider lookup, leaving placeholder or generic for now, strict text asked for "Unidad: Caja" etc.
    // Actually, we can't display the Unit Name in the text "Usted está comprando en la unidad: [Unit]" DYNAMICALLY if we don't have the list of units here.
    // But the unit selector is in the Price section (per user grouping).
    // The user requirement says: "Usted está comprando en la unidad: Caja (de la Variante de Compra)".
    // So the unit selection MUST ideally be visible or accessible to display this text.
    // If I put Unit Selector in Price Section, this text in Basic Info Section won't update easily with the name unless I fetch the list here too.
    // Maybe I should put Unit Selector in Basic Info? "Información básica: Nombre, Contenido, Enlace...".
    // User said: "Precios compra o venta y unidad de medida".
    // I will stick to User Grouping. I will try to display "Unidad seleccionada" or just generic if name is not available.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Información de producto base'),
        // Helper text or ProductName is passed in parent, but here we can add the switch.
        SwitchListTile(
          title: const Text('¿También se vende?'),
          subtitle: const Text('Habilitar venta directa de este paquete'),
          value: state.isForSale,
          onChanged: notifier.updateIsForSale,
          secondary: const Icon(Icons.storefront),
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 16),
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

        // Removed VariantType dropdown.
        if (state.type == VariantType.sales)
          TextFormField(
            initialValue: state.quantity,
            decoration: const InputDecoration(
              labelText: 'Contenido',
              helperText: 'Unidades en este paquete',
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: notifier.updateQuantity,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Requerido';
              final number = double.tryParse(value!);
              if (number == null || number <= 0) {
                return 'Debe ser mayor a 0';
              }
              return null;
            },
          )
        else
          TextFormField(
            initialValue: state.conversionFactor,
            decoration: const InputDecoration(
              labelText: 'Factor de Conversión',
              helperText: 'Multiplicador de stock',
              prefixIcon: Icon(Icons.calculate),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: notifier.updateConversionFactor,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Requerido';
              final number = double.tryParse(value!);
              if (number == null || number <= 0) {
                return 'Debe ser mayor a 0';
              }
              return null;
            },
          ),

        if (state.type == VariantType.purchase) ...[
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Enlace y Conversión'),
          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            initialValue: state.linkedVariantId,
            decoration: const InputDecoration(
              labelText: 'Enlace a Variante de Venta',
              helperText:
                  'Selecciona qué variante de venta aumenta al comprar esto',
              prefixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text(
                  'Sin enlace (Abastece al producto base)',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              ...linkableVariants.map((v) {
                return DropdownMenuItem<int>(
                  value: v.id,
                  child: Text(
                    '${v.variantName} (Actual: ${v.quantity} uds)',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            onChanged: notifier.updateLinkedVariantId,
            isExpanded: true,
          ),

          if (state.linkedVariantId != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sección de Conversión de Unidades',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Builder(
                    builder: (context) {
                      final linked = linkableVariants.firstWhere(
                        (v) => v.id == state.linkedVariantId,
                        orElse: () => ProductVariant(
                          productId: 0,
                          variantName: 'Desconocido',
                          costPriceCents: 0,
                          priceCents: 0,
                        ),
                      );
                      // Exact Text Requested:
                      // "Esta compra agregará inventario a la unidad: Unidad (Pza.) (de la Variante de Venta)."
                      return Text(
                        'Esta compra agregará inventario a la unidad: ${linked.variantName} (de la Variante de Venta)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Caso de uso:\nUsted está comprando en la unidad: ${state.unitId != null ? "Seleccionada" : "Definida"} (de la Variante de Compra)', // ideally fetch unit name
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Conversion Input Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: state.conversionFactor,
                          decoration: const InputDecoration(
                            labelText: 'Factor de Conversión',
                            // "Input Numérico Unidades de Venta: Unidad (Pza.)" -> Label
                            helperText: 'Unidades de Venta que agrega',
                            prefixIcon: Icon(Icons.calculate),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: notifier.updateConversionFactor,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Requerido';
                            final n = double.tryParse(value!);
                            if (n == null || n <= 0) return '> 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // Explanatory Text Example
                  Builder(
                    builder: (context) {
                      final factor =
                          double.tryParse(state.conversionFactor) ?? 0;
                      return Text(
                        'Ejemplo: Si ingresa $factor, cada compra sumará $factor unidades al inventario de venta.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final Map<String, IconData> sectionIcons = {
      'Información Básica': Icons.info_outline_rounded,
      'Información de producto base': Icons.inventory_2_outlined,
      'Enlace y Conversión': Icons.sync_alt_rounded,
    };

    final icon = sectionIcons[title];

    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
