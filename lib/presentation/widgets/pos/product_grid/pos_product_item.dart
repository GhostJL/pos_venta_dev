import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';

class PosProductItem extends ConsumerWidget {
  final Product product;
  final ProductVariant? variant;
  final double quantityInCart;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PosProductItem({
    super.key,
    required this.product,
    this.variant,
    this.quantityInCart = 0,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine effective stock
    final int stock = variant != null
        ? (variant!.stock ?? 0).toInt()
        : (product.stock ?? 0);

    // Calculate Gross Price
    final double basePrice = variant != null ? variant!.price : product.price;
    final Map<int, TaxRate> taxRates = ref.watch(taxRatesMapProvider);

    final double grossPrice = _calculateGrossPrice(
      basePrice,
      product.productTaxes,
      taxRates,
    );

    final String displayName = product.name;
    final String? variantName = variant?.description;

    // Stock Color Logic
    Color stockColor;
    if (stock <= 0) {
      stockColor = colorScheme.error;
    } else if (stock < 10) {
      stockColor = colorScheme.tertiary;
    } else {
      stockColor = colorScheme.primary;
    }

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: quantityInCart > 0
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: quantityInCart > 0 ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Image Placeholder Area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stock Badge (Small & Top)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stock <= 0 ? 'Agotado' : '$stock Disp.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: stockColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Product Name
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),

                    if (variantName != null && variantName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        variantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Price
                    Text(
                      '\$${grossPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Add Button / Cart Quantity
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: quantityInCart > 0
                          ? FilledButton.tonal(
                              onPressed: onTap,
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                              ),
                              child: Text(
                                '${quantityInCart.toInt()} en carrito',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: onTap,
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor:
                                    colorScheme.surfaceContainerHigh,
                                foregroundColor: colorScheme.onSurface,
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text(
                                'Agregar',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateGrossPrice(
    double basePrice,
    List<ProductTax>? taxes,
    Map<int, TaxRate> ratesMap,
  ) {
    if (taxes == null || taxes.isEmpty) return basePrice;

    double taxAmount = 0;
    for (var productTax in taxes) {
      final rateObj = ratesMap[productTax.taxRateId];
      if (rateObj != null) {
        taxAmount += basePrice * rateObj.rate;
      }
    }

    return basePrice + taxAmount;
  }
}
