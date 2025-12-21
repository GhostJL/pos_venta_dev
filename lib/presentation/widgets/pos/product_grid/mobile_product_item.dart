import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';

class MobileProductItem extends ConsumerWidget {
  final Product product;
  final ProductVariant? variant;
  final double quantityInCart;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const MobileProductItem({
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

    // Cart State Logic
    final isSelected = quantityInCart > 0;
    final cardColor = isSelected
        ? colorScheme.primaryContainer.withValues(
            alpha: 0.1,
          ) // Subtle primary tint
        : colorScheme.surface;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // Remove heavy borders, use subtle side border only if needed or just transparency difference
        side: isSelected
            ? BorderSide(color: colorScheme.primary.withValues(alpha: 0.2))
            : BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Display
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  image:
                      (variant?.photoUrl ?? product.photoUrl) != null &&
                          (variant?.photoUrl ?? product.photoUrl)!.isNotEmpty
                      ? DecorationImage(
                          image:
                              (variant?.photoUrl ?? product.photoUrl)!
                                  .startsWith('http')
                              ? NetworkImage(
                                  (variant?.photoUrl ?? product.photoUrl)!,
                                )
                              : FileImage(
                                      File(
                                        (variant?.photoUrl ??
                                            product.photoUrl)!,
                                      ),
                                    )
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    (variant?.photoUrl ?? product.photoUrl) == null ||
                        (variant?.photoUrl ?? product.photoUrl)!.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROW 1: Name
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ROW 2: Price | Details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$${grossPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        if (stock <= 10 || variantName != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              [
                                if (variantName != null) variantName,
                                if (stock <= 0)
                                  'Agotado'
                                else if (stock <= 10)
                                  '$stock disp.',
                              ].join(' • '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: stock <= 0
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // ROW 3: Actions (only if space needed, but typically button is right aligned or below)
                    // For this minimalist design, let's keep the button comfortably placed.
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 36,
                        child: quantityInCart > 0
                            ? FilledButton.icon(
                                onPressed: onTap,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  backgroundColor:
                                      colorScheme.primary, // Use Primary
                                  foregroundColor: colorScheme.onPrimary,
                                  visualDensity: VisualDensity.compact,
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.check, size: 16),
                                label: Text(
                                  '${quantityInCart.toInt()} en carrito',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : FilledButton.tonal(
                                onPressed: onTap,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  backgroundColor:
                                      colorScheme.surfaceContainerHigh,
                                  foregroundColor: colorScheme.onSurface,
                                  visualDensity: VisualDensity.compact,
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Agregar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
