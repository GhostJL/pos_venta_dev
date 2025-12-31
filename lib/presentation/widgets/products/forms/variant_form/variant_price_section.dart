import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantPriceSection extends ConsumerWidget {
  final ProductVariant? variant;
  final VariantType? initialType;
  final TextEditingController priceController;
  final TextEditingController costController;
  final TextEditingController wholesalePriceController;
  final TextEditingController marginController;
  final FocusNode? priceFocus;
  final FocusNode? costFocus;
  final FocusNode? marginFocus;

  const VariantPriceSection({
    super.key,
    this.variant,
    this.initialType,
    required this.priceController,
    required this.costController,
    required this.wholesalePriceController,
    required this.marginController,
    this.priceFocus,
    this.costFocus,
    this.marginFocus,
  });

  // ... (build method remains mostly the same, ensuring variables match)

  Widget _buildMoneyField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required ThemeData theme,
    bool isPrimary = false,
    bool isPercentage = false,
    FocusNode? focusNode,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixText: isPercentage ? '' : '\$ ',
        suffixText: isPercentage ? '%' : '',
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
        if (val == null || val.isEmpty) {
          return isPercentage ? null : 'Requerido'; // Margin optional
        }
        final n = double.tryParse(val);
        if (n == null || n < 0) return 'Inválido';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = variantFormProvider(variant, initialType: initialType);

    final unitId = ref.watch(provider.select((s) => s.unitId));
    final isSoldByWeight = ref.watch(provider.select((s) => s.isSoldByWeight));
    final isForSale = ref.watch(provider.select((s) => s.isForSale));
    final type = ref.watch(provider.select((s) => s.type));

    final notifier = ref.read(provider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3. Campos de Costo
        _buildMoneyField(
          label: type == VariantType.purchase
              ? 'Precio Compra'
              : 'Costo Unitario',
          controller: costController,
          focusNode: costFocus,
          icon: Icons.shopping_cart_checkout_rounded,
          theme: theme,
        ),

        if (type == VariantType.sales) ...[
          const SizedBox(height: 12),
          // 4. Margen y Venta en fila separada
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoneyField(
                label: '% Ganancia',
                controller: marginController,
                focusNode: marginFocus,
                icon: Icons.show_chart_rounded,
                theme: theme,
                isPercentage: true,
              ),
              const SizedBox(height: 12),
              _buildMoneyField(
                label: 'Precio Venta',
                controller: priceController,
                focusNode: priceFocus,
                icon: Icons.sell_rounded,
                theme: theme,
                isPrimary: true,
              ),
            ],
          ),
        ],

        // 4. Precio Mayorista
        if (type == VariantType.sales) ...[
          const SizedBox(height: 12),
          _buildMoneyField(
            label: 'Precio Mayorista (Opcional)',
            controller: wholesalePriceController,
            icon: Icons.groups_rounded,
            theme: theme,
          ),
        ],

        // 5. Indicador de Margen (UX Sugerida)
        if (type == VariantType.sales)
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
            color: isNegative
                ? theme.colorScheme.error
                : const Color(0xFF00C853),
          ),
          const SizedBox(width: 6),
          Text(
            'Margen de utilidad: ${margin.toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isNegative
                  ? theme.colorScheme.error
                  : const Color(0xFF00C853), // AppTheme.transactionSuccess
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
