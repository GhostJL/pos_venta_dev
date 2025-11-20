import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

/// Compact list tile widget for displaying purchase items
/// Useful for showing items in lists, dialogs, or as part of other screens
class PurchaseItemListTile extends StatelessWidget {
  final PurchaseItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showActions;

  const PurchaseItemListTile({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
          child: Icon(Icons.inventory_2, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          item.productName ?? 'Producto Desconocido',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${item.quantity} ${item.unitOfMeasure} × \$${item.unitCost.toStringAsFixed(2)}',
            ),
            if (item.lotNumber != null)
              Text(
                'Lote: ${item.lotNumber}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            Text(
              dateFormat.format(item.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (item.taxCents > 0)
                  Text(
                    'IVA: \$${item.tax.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'view') {
                    if (item.id != null) {
                      context.push('/purchase-items/${item.id}');
                    }
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 20),
                        SizedBox(width: 8),
                        Text('Ver Detalle'),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        onTap:
            onTap ??
            () {
              if (item.id != null) {
                context.push('/purchase-items/${item.id}');
              }
            },
      ),
    );
  }
}
