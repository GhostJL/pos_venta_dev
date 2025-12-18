import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/providers.dart';

class VariantPriceSection extends ConsumerWidget {
  final ProductVariant? variant;
  final TextEditingController priceController;
  final TextEditingController costController;
  final TextEditingController wholesalePriceController;

  const VariantPriceSection({
    super.key,
    this.variant,
    required this.priceController,
    required this.costController,
    required this.wholesalePriceController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = variantFormProvider(variant);

    final unitId = ref.watch(provider.select((s) => s.unitId));
    final isSoldByWeight = ref.watch(provider.select((s) => s.isSoldByWeight));
    final isForSale = ref.watch(provider.select((s) => s.isForSale));
    final type = ref.watch(provider.select((s) => s.type));

    final notifier = ref.read(provider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Configuración de Medida',
          Icons.straighten_rounded,
        ),

        // 1. Selector de Unidad
        Consumer(
          builder: (context, ref, child) {
            final unitsAsync = ref.watch(unitListProvider);
            return unitsAsync.when(
              data: (units) => DropdownButtonFormField<int>(
                initialValue: unitId,
                decoration: const InputDecoration(
                  labelText: 'Unidad de medida',
                  prefixIcon: Icon(Icons.scale_rounded),
                ),
                items: units
                    .map(
                      (u) => DropdownMenuItem(value: u.id, child: Text(u.name)),
                    )
                    .toList(),
                onChanged: notifier.updateUnitId,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error al cargar unidades'),
            );
          },
        ),

        const SizedBox(height: 16),

        // 2. Venta por Peso (Switch Estilizado)
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: const Text(
              'Venta por peso / granel',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Habilitar decimales en cantidad al vender'),
            value: isSoldByWeight,
            onChanged: notifier.updateIsSoldByWeight,
            secondary: Icon(
              Icons.monitor_weight_outlined,
              color: theme.colorScheme.primary,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),

        const SizedBox(height: 32),
        _buildSectionHeader(
          context,
          'Valores Financieros',
          Icons.monetization_on_outlined,
        ),

        // 3. Campos de Costo y Venta
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMoneyField(
                label: type == VariantType.purchase
                    ? 'Precio Compra'
                    : 'Costo Unitario',
                controller: costController,
                icon: Icons.shopping_cart_checkout_rounded,
                theme: theme,
              ),
            ),
            if (type == VariantType.sales || isForSale) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildMoneyField(
                  label: 'Precio Venta',
                  controller: priceController,
                  icon: Icons.sell_rounded,
                  theme: theme,
                  isPrimary: true,
                ),
              ),
            ],
          ],
        ),

        // 4. Precio Mayorista
        if (type == VariantType.sales || isForSale) ...[
          const SizedBox(height: 20),
          _buildMoneyField(
            label: 'Precio Mayorista (Opcional)',
            controller: wholesalePriceController,
            icon: Icons.groups_rounded,
            theme: theme,
          ),
        ],

        // 5. Indicador de Margen (UX Sugerida)
        if (type == VariantType.sales || isForSale)
          ListenableBuilder(
            listenable: Listenable.merge([priceController, costController]),
            builder: (context, _) => _buildMarginIndicator(
              context,
              costController.text,
              priceController.text,
            ),
          ),
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
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required ThemeData theme,
    bool isPrimary = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '\$ ',
        prefixIcon: Icon(icon),
        enabledBorder: isPrimary
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              )
            : null,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Requerido';
        final n = double.tryParse(val);
        if (n == null || n < 0) return 'Inválido';
        return null;
      },
    );
  }

  Widget _buildMarginIndicator(
    BuildContext context,
    String costStr,
    String priceStr,
  ) {
    final cost = double.tryParse(costStr) ?? 0;
    final price = double.tryParse(priceStr) ?? 0;
    final theme = Theme.of(context);

    if (cost <= 0 || price <= 0) return const SizedBox.shrink();

    final margin = ((price - cost) / price) * 100;
    final isNegative = margin < 0;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 4),
      child: Row(
        children: [
          Icon(
            isNegative
                ? Icons.warning_amber_rounded
                : Icons.trending_up_rounded,
            size: 14,
            color: isNegative ? theme.colorScheme.error : Colors.green,
          ),
          const SizedBox(width: 6),
          Text(
            'Margen de utilidad: ${margin.toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isNegative ? theme.colorScheme.error : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
