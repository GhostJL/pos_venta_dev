import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No hay productos agregados',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isWide = MediaQuery.of(context).size.width > 600;

        return Card(
          elevation: 2,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onEditItem(index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isWide
                  ? _buildHorizontalLayout(context, item, index)
                  : _buildVerticalLayout(context, item, index),
            ),
          ),
        );
      },
    );
  }

  /// Layout para pantallas anchas (tablet/escritorio)
  Widget _buildHorizontalLayout(
    BuildContext context,
    PurchaseItem item,
    int index,
  ) {
    return Row(
      children: [
        /// Info producto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName ?? 'Producto',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity} ${item.unitOfMeasure} × \$${item.unitCost.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        /// Total
        Text(
          '\$${item.total.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),

        const SizedBox(width: 16),

        /// Acciones
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: Colors.blue.shade600,
              onPressed: () => onEditItem(index),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: Colors.red.shade600,
              onPressed: () => onRemoveItem(index),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ],
    );
  }

  /// Layout para pantallas móviles
  Widget _buildVerticalLayout(
    BuildContext context,
    PurchaseItem item,
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Encabezado
        Text(
          item.productName ?? 'Producto',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.quantity} ${item.unitOfMeasure} × \$${item.unitCost.toStringAsFixed(2)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),

        const SizedBox(height: 12),

        /// Total + acciones
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${item.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.blue.shade600,
                  onPressed: () => onEditItem(index),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red.shade600,
                  onPressed: () => onRemoveItem(index),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
