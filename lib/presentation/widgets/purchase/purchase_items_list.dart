import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

class PurchaseItemsList extends StatelessWidget {
  final List<PurchaseItem> items;
  final Purchase purchase;

  const PurchaseItemsList({
    super.key,
    required this.items,
    required this.purchase,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _PurchaseItemTile(item: items[index], purchase: purchase);
      },
    );
  }
}

class _PurchaseItemTile extends ConsumerWidget {
  final Purchase purchase;
  final PurchaseItem item;

  const _PurchaseItemTile({required this.item, required this.purchase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFullyReceived = item.quantityReceived >= item.quantity;
    final isPartiallyReceived =
        item.quantityReceived > 0 && item.quantityReceived < item.quantity;
    final isCancelled = purchase.status == PurchaseStatus.cancelled;

    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    String statusText;

    if (isFullyReceived) {
      statusColor = const Color(0xFF059669);
      statusBgColor = const Color(0xFFD1FAE5);
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Completado';
    } else if (isPartiallyReceived) {
      statusColor = const Color(0xFFD97706);
      statusBgColor = const Color(0xFFFEF3C7);
      statusIcon = Icons.schedule_rounded;
      statusText = '${item.quantityReceived} de ${item.quantity}';
    } else if (isCancelled) {
      statusColor = const Color(0xFFDC2626);
      statusBgColor = const Color(0xFFFEE2E2);
      statusIcon = Icons.cancel_rounded;
      statusText = 'Cancelado';
    } else {
      statusColor = const Color(0xFF2563EB);
      statusBgColor = const Color(0xFFDEEBFF);
      statusIcon = Icons.pending_rounded;
      statusText = 'Pendiente';
    }

    final productsAsync = ref.watch(productNotifierProvider);

    return productsAsync.when(
      data: (products) {
        final product = products
            .where((p) => p.id == item.productId)
            .firstOrNull;

        ProductVariant? variant;
        if (product != null && item.variantId != null) {
          variant = product.variants
              ?.where((v) => v.id == item.variantId)
              .firstOrNull;
        }

        double displayQuantity = item.quantity;
        String displayUnit = item.unitOfMeasure;
        double displayCost = item.unitCost;

        if (variant != null) {
          displayQuantity = item.quantity / variant.quantity;
          displayUnit = 'cajas/paq';
          if (displayQuantity > 0) {
            displayCost = (item.subtotalCents / 100.0) / displayQuantity;
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header: Nombre del producto y precio total
                Row(
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .center,
                  children: [
                    Text(
                      item.productName ?? 'Producto #${item.productId}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (variant != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withAlpha(55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_rounded,
                              size: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${variant.quantity.toStringAsFixed(0)} un/caja',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                /// Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),

                const SizedBox(height: 12),

                /// Cantidad y precio unitario
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.primary,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${displayQuantity.toStringAsFixed(displayQuantity % 1 == 0 ? 0 : 2)} $displayUnit',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const TextSpan(text: ' × '),
                            TextSpan(
                              text: '\$${displayCost.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const TextSpan(text: ' c/u'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Estado de recepción
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '\$${(item.totalCents / 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
