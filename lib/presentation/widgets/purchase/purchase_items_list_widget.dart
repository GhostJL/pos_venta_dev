import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

class PurchaseItemsListWidget extends StatelessWidget {
  final List<PurchaseItem> items;
  final Map<int, Product> productMap;
  final Function(int index) onEditItem;
  final Function(int index) onRemoveItem;
  final Function(int index, double newQuantity) onQuantityChanged;

  const PurchaseItemsListWidget({
    super.key,
    required this.items,
    required this.productMap,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.onQuantityChanged,
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
        final product = productMap[item.productId];
        final isWide = MediaQuery.of(context).size.width > 600;

        return Card(
          elevation: 2,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onEditItem(index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isWide
                  ? _buildHorizontalLayout(context, item, product, index)
                  : _buildVerticalLayout(context, item, product, index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceInfo(
    BuildContext context,
    PurchaseItem item,
    Product? product,
  ) {
    if (product == null) return const SizedBox.shrink();

    // Check if it's a variant
    final isVariant = item.variantId != null;
    ProductVariant? variant;
    if (isVariant) {
      variant = product.variants
          ?.where((v) => v.id == item.variantId)
          .firstOrNull;
    }

    // Calculate quantities
    double displayQuantity = item.quantity;
    String displayUnit = item.unitOfMeasure;
    double displayCost = item.unitCost;
    double referenceCost = product.costPriceCents / 100.0;

    if (isVariant && variant != null) {
      // Show in packs
      displayQuantity = item.quantity / variant.quantity;
      displayUnit = 'cajas/paq'; // Or use variant description?
      // Calculate pack cost from subtotal to be precise
      // subtotal = 32000. packs = 2. cost = 16000.
      displayCost = (item.subtotalCents / 100.0) / displayQuantity;
      referenceCost = variant.costPriceCents / 100.0;
    }

    final diff = displayCost - referenceCost;
    final hasDiff = diff.abs() > 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isVariant && variant != null)
          Text(
            '${displayQuantity.toStringAsFixed(displayQuantity % 1 == 0 ? 0 : 2)} x ${variant.description} (${variant.quantity.toStringAsFixed(0)} u)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            '${item.quantity} ${item.unitOfMeasure}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black87),
          ),

        const SizedBox(height: 2),

        Row(
          children: [
            Text(
              '\$${displayCost.toStringAsFixed(2)} c/u',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            if (hasDiff) ...[
              const SizedBox(width: 8),
              Icon(
                diff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: diff > 0 ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 2),
              Text(
                '\$${referenceCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Layout para pantallas anchas (tablet/escritorio)
  Widget _buildHorizontalLayout(
    BuildContext context,
    PurchaseItem item,
    Product? product,
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
              _buildPriceInfo(context, item, product),
            ],
          ),
        ),

        /// Quantity Controls
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              onPressed: () {
                // Determine step size. If variant, maybe step by variant quantity?
                // Or just -1? Usually -1 pack if it's a pack.
                // But item.quantity is in base units.
                // If I added a pack of 12, quantity is 12.
                // If I click minus, do I want 11 or 0?
                // Usually we want to decrement by the "pack size".

                double step = 1.0;
                if (item.variantId != null && product != null) {
                  final variant = product.variants
                      ?.where((v) => v.id == item.variantId)
                      .firstOrNull;
                  if (variant != null) {
                    step = variant.quantity;
                  }
                }

                if (item.quantity > step) {
                  onQuantityChanged(index, item.quantity - step);
                }
              },
              color: Colors.grey.shade600,
            ),
            Text(
              item.quantity.toStringAsFixed(
                0,
              ), // Assuming integer quantities for now
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: () {
                double step = 1.0;
                if (item.variantId != null && product != null) {
                  final variant = product.variants
                      ?.where((v) => v.id == item.variantId)
                      .firstOrNull;
                  if (variant != null) {
                    step = variant.quantity;
                  }
                }
                onQuantityChanged(index, item.quantity + step);
              },
              color: Colors.blue.shade600,
            ),
          ],
        ),

        const SizedBox(width: 16),

        /// Total
        SizedBox(
          width: 100,
          child: Text(
            '\$${item.total.toStringAsFixed(2)}',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
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
    Product? product,
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
        _buildPriceInfo(context, item, product),

        const SizedBox(height: 12),

        /// Controls Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Quantity Controls
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () {
                    double step = 1.0;
                    if (item.variantId != null && product != null) {
                      final variant = product.variants
                          ?.where((v) => v.id == item.variantId)
                          .firstOrNull;
                      if (variant != null) {
                        step = variant.quantity;
                      }
                    }
                    if (item.quantity > step) {
                      onQuantityChanged(index, item.quantity - step);
                    }
                  },
                  color: Colors.grey.shade600,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.quantity.toStringAsFixed(0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () {
                    double step = 1.0;
                    if (item.variantId != null && product != null) {
                      final variant = product.variants
                          ?.where((v) => v.id == item.variantId)
                          .firstOrNull;
                      if (variant != null) {
                        step = variant.quantity;
                      }
                    }
                    onQuantityChanged(index, item.quantity + step);
                  },
                  color: Colors.blue.shade600,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            Text(
              '\$${item.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
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
}
