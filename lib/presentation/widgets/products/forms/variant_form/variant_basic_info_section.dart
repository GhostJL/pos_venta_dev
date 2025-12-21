import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantBasicInfoSection extends ConsumerWidget {
  final ProductVariant? variant;
  final List<ProductVariant>? availableVariants;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController conversionController;

  const VariantBasicInfoSection({
    super.key,
    this.variant,
    this.availableVariants,
    required this.nameController,
    required this.quantityController,
    required this.conversionController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = variantFormProvider(variant);

    // Watch only necessary fields to avoid full rebuilds on typing
    final isForSale = ref.watch(provider.select((s) => s.isForSale));
    final type = ref.watch(provider.select((s) => s.type));
    final linkedVariantId = ref.watch(
      provider.select((s) => s.linkedVariantId),
    );

    final notifier = ref.read(provider.notifier);

    // Filtrar variantes para enlazar (Solo de tipo venta)
    final linkableVariants =
        availableVariants?.where((v) {
          if (v.id != null && v.id == variant?.id) return false;
          if (v.id == null) return false;
          return v.type == VariantType.sales;
        }).toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- SECCIÓN 1: VISIBILIDAD ---
        _buildSectionHeader(
          context,
          'Visibilidad en Catálogo',
          Icons.visibility_outlined,
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: const Text(
              '¿Habilitar para la venta?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Permite seleccionar este paquete directamente en el carrito',
            ),
            value: isForSale,
            onChanged: notifier.updateIsForSale,
            secondary: Icon(Icons.storefront, color: theme.colorScheme.primary),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // --- SECCIÓN 2: DATOS BÁSICOS ---
        _buildSectionHeader(
          context,
          'Información Básica',
          Icons.edit_note_rounded,
        ),
        TextFormField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Nombre de la Variante',
            hintText: 'Ej: Caja con 12 pzas',
            prefixIcon: Icon(Icons.label_important_outline),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo requerido' : null,
        ),

        const SizedBox(height: 20),

        // Campo dinámico basado en tipo (Contenido o Factor)
        if (type == VariantType.sales)
          _buildNumberField(
            label: 'Unidades por paquete',
            helper: 'Cantidad de piezas físicas que contiene',
            controller: quantityController,
            icon: Icons.inventory_2_outlined,
          )
        else
          _buildNumberField(
            label: 'Factor de Conversión',
            helper: 'Cuántas unidades del producto base representa',
            controller: conversionController,
            icon: Icons.calculate_outlined,
          ),

        // --- SECCIÓN 3: ENLACE (SOLO COMPRA) ---
        if (type == VariantType.purchase) ...[
          const SizedBox(height: 32),
          _buildSectionHeader(
            context,
            'Flujo de Inventario',
            Icons.sync_alt_rounded,
          ),

          DropdownButtonFormField<int>(
            initialValue: linkedVariantId,
            decoration: const InputDecoration(
              labelText: 'Vincular a Variante de Venta',
              prefixIcon: Icon(Icons.link_rounded),
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text(
                  'Sin enlace (Abastece stock base)',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              ...linkableVariants.map(
                (v) => DropdownMenuItem<int>(
                  value: v.id,
                  child: Text(
                    '${v.variantName} (En stock: ${v.quantity.toInt()} uds)',
                  ),
                ),
              ),
            ],
            onChanged: notifier.updateLinkedVariantId,
            isExpanded: true,
          ),

          if (linkedVariantId != null) ...[
            const SizedBox(height: 20),
            ListenableBuilder(
              listenable: conversionController,
              builder: (context, child) {
                return _buildConversionCard(
                  context,
                  linkedVariantId,
                  conversionController.text,
                  linkableVariants,
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required String helper,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        prefixIcon: Icon(icon),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Requerido';
        if (double.tryParse(val) == null || double.tryParse(val)! <= 0) {
          return '> 0';
        }
        return null;
      },
    );
  }

  Widget _buildConversionCard(
    BuildContext context,
    int? linkedVariantId,
    String conversionFactor,
    List<ProductVariant> linkable,
  ) {
    final theme = Theme.of(context);
    final linked = linkable.firstWhere(
      (v) => v.id == linkedVariantId,
      orElse: () => ProductVariant(
        productId: 0,
        variantName: '...',
        costPriceCents: 0,
        priceCents: 0,
      ),
    );
    final factor = double.tryParse(conversionFactor) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_fix_high_rounded,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Regla de conversión activa',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              children: [
                const TextSpan(
                  text:
                      'Al comprar 1 unidad de esta variante, el sistema sumará ',
                ),
                TextSpan(
                  text: '$factor unidades',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(
                  text: ' automáticamente a la variante de venta: ',
                ),
                TextSpan(
                  text: linked.variantName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
