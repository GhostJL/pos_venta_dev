import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

/// Widget reutilizable para mostrar la lista de items de una compra.
///
/// Muestra cada item con:
/// - Nombre del producto
/// - Cantidad y precio unitario
/// - Estado de recepción (si aplica)
/// - Total del item
class PurchaseItemsList extends StatelessWidget {
  final List<PurchaseItem> items;

  const PurchaseItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return _PurchaseItemTile(item: items[index]);
      },
    );
  }
}

class _PurchaseItemTile extends StatelessWidget {
  final PurchaseItem item;

  const _PurchaseItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isFullyReceived = item.quantityReceived >= item.quantity;
    final isPartiallyReceived =
        item.quantityReceived > 0 && item.quantityReceived < item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Producto #${item.productId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${item.quantity} ${item.unitOfMeasure} x \$${(item.unitCostCents / 100).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (item.quantityReceived > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          isFullyReceived
                              ? Icons.check_circle
                              : Icons.timelapse,
                          size: 14,
                          color: isFullyReceived ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Recibido: ${item.quantityReceived} / ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isFullyReceived
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '\$${(item.totalCents / 100).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
