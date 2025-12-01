import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

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

class _PurchaseItemTile extends StatelessWidget {
  final Purchase purchase;
  final PurchaseItem item;

  const _PurchaseItemTile({required this.item, required this.purchase});

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    item.productName ?? 'Producto #${item.productId}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  /// Cantidad × precio unitario
                  Text(
                    '${item.quantity} ${item.unitOfMeasure} × \$${(item.unitCostCents / 100).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
  }
}
