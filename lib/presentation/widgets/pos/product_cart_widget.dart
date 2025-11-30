import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductVariant? variant;
  final bool isMobile;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.variant,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasStock = (product.stock ?? 0) > 0;
    final displayName = variant != null
        ? '${product.name}\n${variant!.description}'
        : product.name;
    final displayPrice = variant != null
        ? (variant!.priceCents / 100)
        : product.price;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: hasStock ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nombre del producto (simplificado)
              Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 13 : 14,
                  color: hasStock ? Colors.black87 : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Stock y Precio en una fila
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Stock badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: hasStock
                          ? Colors.green.withAlpha(30)
                          : Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: hasStock ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      product.stock?.toStringAsFixed(0) ?? '0',
                      style: TextStyle(
                        color: hasStock
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Precio
                  Text(
                    '\$${displayPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 15 : 16,
                      color: Theme.of(context).primaryColor,
                    ),
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
