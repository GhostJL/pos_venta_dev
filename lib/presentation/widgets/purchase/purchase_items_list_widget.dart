import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

/// Widget that displays the list of purchase items with edit/delete actions
class PurchaseItemsListWidget extends StatelessWidget {
  final List<PurchaseItem> items;
  final Function(int index) onEditItem;
  final Function(int index) onRemoveItem;

  const PurchaseItemsListWidget({
    super.key,
    required this.items,
    required this.onEditItem,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No hay productos agregados'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.productName ?? 'Producto'),
          subtitle: Text(
            '${item.quantity} ${item.unitOfMeasure} x \$${item.unitCost.toStringAsFixed(2)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEditItem(index),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onRemoveItem(index),
                tooltip: 'Eliminar',
              ),
            ],
          ),
          onTap: () => onEditItem(index),
        );
      },
    );
  }
}
