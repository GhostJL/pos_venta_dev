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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
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
    IconData statusIcon;
    String statusText;

    if (isFullyReceived) {
      statusColor = Colors.green.shade700;
      statusIcon = Icons.check_circle;
      statusText = 'Completado';
    } else if (isPartiallyReceived) {
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.timelapse;
      statusText = 'Recibido: ${item.quantityReceived} / ${item.quantity}';
    } else if (isCancelled) {
      statusColor = Colors.red.shade700;
      statusIcon = Icons.cancel;
      statusText = 'Cancelado';
    } else {
      statusColor = Colors.blue.shade700;
      statusIcon = Icons.pending;
      statusText = 'Pendiente';
    }

    // Fetch product/variant to know if it's a pack
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
          // Calculate pack cost from subtotal
          if (displayQuantity > 0) {
            displayCost = (item.subtotalCents / 100.0) / displayQuantity;
          }
        }

        return Card(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Nombre del producto
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName ?? 'Producto #${item.productId}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (variant != null)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.purple.shade100,
                                ),
                              ),
                              child: Text(
                                '${variant.quantity.toStringAsFixed(0)} un/caja',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      /// Cantidad × precio unitario
                      Text(
                        '${displayQuantity.toStringAsFixed(displayQuantity % 1 == 0 ? 0 : 2)} $displayUnit × \$${displayCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),

                      /// Estado de recepción
                      Row(
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Total del item
                Text(
                  '\$${(item.totalCents / 100).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(), // Or skeleton
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
