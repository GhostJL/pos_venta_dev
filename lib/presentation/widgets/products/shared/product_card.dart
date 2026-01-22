import 'dart:io';

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
    // Stock Removed from Card
    const hasStock = true; // Always enable tap for now, or depend on isActive

    final double displayValue = showCost
        ? (variant?.costPriceCents ?? product.costPriceCents) / 100
        : (variant?.priceCents ?? (product.price * 100)) / 100;

    final photoUrl = variant?.photoUrl ?? product.photoUrl;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photoUrl != null && photoUrl.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: photoUrl.startsWith('http')
                              ? NetworkImage(photoUrl)
                              : FileImage(File(photoUrl)) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Nombre del producto
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 14 : 15,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),

                        /// Variante como badge
                        if (variant != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              variant!.description,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isMobile ? 11 : 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// Stock y Precio/Costo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stock badge
                  // Stock badge Removed

                  // Precio o Costo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showCost)
                        Text(
                          'Costo',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                        ),
                      Text(
                        '\$${displayValue.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 15 : 16,
                              color: Theme.of(context).colorScheme.onSurface,
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
