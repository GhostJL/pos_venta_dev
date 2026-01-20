import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';
import 'package:posventa/presentation/widgets/common/quick_action_wrapper.dart';

class PosProductItem extends ConsumerStatefulWidget {
  final Product product;
  final ProductVariant? variant;
  final double quantityInCart;
  final VoidCallback onTap; // Used for Add / +
  final VoidCallback? onRemove; // Used for Remove / -
  final VoidCallback? onDelete; // Used for Delete
  final VoidCallback onLongPress;
  final bool isFocused;

  const PosProductItem({
    super.key,
    required this.product,
    this.variant,
    this.quantityInCart = 0,
    required this.onTap,
    this.onRemove,
    this.onDelete,
    required this.onLongPress,
    this.isFocused = false,
  });

  @override
  ConsumerState<PosProductItem> createState() => _PosProductItemState();
}

class _PosProductItemState extends ConsumerState<PosProductItem> {
  bool _isHovering = false;

  void _onEnter(PointerEvent details) {
    setState(() => _isHovering = true);
  }

  void _onExit(PointerEvent details) {
    setState(() => _isHovering = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine effective stock
    final int stock = widget.variant != null
        ? (widget.variant!.stock ?? 0).toInt()
        : (widget.product.stock ?? 0);

    // Calculate Gross Price
    // Global Settings
    final settingsAsync = ref.watch(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;
    final useTax = settingsAsync.value?.useTax ?? true;

    // Calculate Gross Price
    final double basePrice = widget.variant != null
        ? widget.variant!.price
        : widget.product.price;
    final Map<int, TaxRate> taxRates = ref.watch(taxRatesMapProvider);

    final double grossPrice = useTax
        ? _calculateGrossPrice(basePrice, widget.product.productTaxes, taxRates)
        : basePrice;

    final String displayName = widget.product.name;
    final String? variantName = widget.variant?.description;

    // Stock Color Logic
    Color stockColor;
    if (stock <= 0) {
      stockColor = colorScheme.error;
    } else if (stock < 10) {
      stockColor = colorScheme
          .tertiary; // Cyan for low stock warning but keeping it cool
    } else {
      stockColor = colorScheme.primary;
    }

    final double scale = _isHovering || widget.isFocused ? 1.02 : 1.0;
    final double elevation = _isHovering || widget.isFocused ? 4.0 : 0.0;

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(scale, scale, 1.0),
        child: QuickActionWrapper(
          onAdd: widget.onTap,
          onRemove: widget.onRemove,
          onDelete: widget.onDelete,
          child: Card(
            elevation: elevation,
            shadowColor: Colors.black.withValues(alpha: 0.2), // Softer shadow
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: widget.isFocused
                    ? colorScheme.primary
                    : (widget.quantityInCart > 0
                          ? colorScheme.primary
                          : (_isHovering
                                ? colorScheme.primary.withValues(alpha: 0.5)
                                : colorScheme.outlineVariant)),
                width: widget.isFocused || widget.quantityInCart > 0 ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Image Area
                  Expanded(
                    flex: 9, // Reduced slightly to give more room to text
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        image:
                            (widget.variant?.photoUrl ??
                                        widget.product.photoUrl) !=
                                    null &&
                                (widget.variant?.photoUrl ??
                                        widget.product.photoUrl)!
                                    .isNotEmpty
                            ? DecorationImage(
                                image: ResizeImage(
                                  (widget.variant?.photoUrl ??
                                              widget.product.photoUrl)!
                                          .startsWith('http')
                                      ? NetworkImage(
                                          (widget.variant?.photoUrl ??
                                              widget.product.photoUrl)!,
                                        )
                                      : FileImage(
                                              File(
                                                (widget.variant?.photoUrl ??
                                                    widget.product.photoUrl)!,
                                              ),
                                            )
                                            as ImageProvider,
                                  width: 300, // Optimize memory usage
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          (widget.variant?.photoUrl ??
                                      widget.product.photoUrl) ==
                                  null ||
                              (widget.variant?.photoUrl ??
                                      widget.product.photoUrl)!
                                  .isEmpty
                          ? Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),

                  // Content Area
                  Expanded(
                    flex: 13, // Increased to Prevent Overflow
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ), // Reduced Padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stock Badge (Small & Top)
                          if (useInventory) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, // Slightly tighter
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: stockColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    stock <= 0
                                        ? Icons.error_outline
                                        : Icons.check_circle_outline,
                                    size: 10,
                                    color: stockColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    // Prevent text overflow in badge
                                    child: Text(
                                      stock <= 0 ? 'Agotado' : '$stock Disp.',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: stockColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4), // Reduced spacing
                          ],

                          // Product Name
                          Text(
                            displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                              fontSize: 12, // Slightly smaller font
                            ),
                          ),

                          if (variantName != null &&
                              variantName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              variantName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10, // Smaller font
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
                              fontSize: 15, // Adjusted
                            ),
                          ),

                          const SizedBox(height: 4), // Reduced spacing
                          // Add Button / Cart Quantity
                          SizedBox(
                            width: double.infinity,
                            height: 30, // Slightly reduced height 32->30
                            child: widget.quantityInCart > 0
                                ? FilledButton.tonal(
                                    onPressed: widget.onTap,
                                    style: FilledButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor:
                                          colorScheme.primaryContainer,
                                      foregroundColor:
                                          colorScheme.onPrimaryContainer,
                                    ),
                                    child: Text(
                                      '${widget.quantityInCart.toInt()} en carrito',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : FilledButton.icon(
                                    onPressed: widget.onTap,
                                    style: FilledButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: _isHovering
                                          ? colorScheme.primary
                                          : colorScheme.surfaceContainerHigh,
                                      foregroundColor: _isHovering
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
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
