import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: Listenable.merge([
              salePriceController,
              costPriceController,
            ]),
            builder: (context, _) => _buildMarginIndicator(
              context,
              costPriceController.text,
              salePriceController.text,
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(
            isNegative
                ? Icons.warning_amber_rounded
                : Icons.trending_up_rounded,
            size: 14,
            color: isNegative
                ? theme.colorScheme.error
                : const Color(0xFF00C853), // AppTheme.transactionSuccess
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
