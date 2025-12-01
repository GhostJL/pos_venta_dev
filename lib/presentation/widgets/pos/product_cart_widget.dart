import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductVariant? variant;
  final bool isMobile;
  final VoidCallback onTap;
  final bool showCost;

  const ProductCard({
    super.key,
    required this.product,
    this.variant,
    required this.isMobile,
    required this.onTap,
    this.showCost = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasStock = (product.stock ?? 0) > 0;

    final double displayValue = showCost
        ? (variant?.costPriceCents ?? product.costPriceCents) / 100
        : (variant?.priceCents ?? (product.price * 100)) / 100;

    return Card(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: (hasStock || showCost) ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Nombre del producto
              Text(
                product.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 14 : 15,
                  color: hasStock ? Colors.black87 : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              /// Variante como badge
              if (variant != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    variant!.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 11 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              const Spacer(),

              /// Stock y Precio/Costo en la parte inferior
              Row(
                crossAxisAlignment: .end,
                mainAxisAlignment: .spaceBetween,
                children: [
                  // Stock badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: hasStock
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${product.stock?.toStringAsFixed(0) ?? '0'} en stock',
                      style: TextStyle(
                        color: hasStock
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Precio o Costo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showCost)
                        Text(
                          'Costo',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                        ),
                      Text(
                        '\$${displayValue.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 15 : 16,
                              color: showCost
                                  ? Colors.blue.shade700
                                  : Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
