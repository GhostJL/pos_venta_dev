import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';
import 'package:posventa/presentation/providers/inventory_lot_providers.dart';

class InventoryCardWidget extends ConsumerWidget {
  final Inventory inventory;
  final Product product;
  final ProductVariant variant;
  final Warehouse? warehouse;

  const InventoryCardWidget({
    super.key,
    required this.inventory,
    required this.product,
    required this.variant,
    this.warehouse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stock Logic
    final double stock = inventory.quantityOnHand;
    // Prefer inventory-specific minStock, fallback to variant global minStock
    final double minStock = (inventory.minStock ?? variant.stockMin ?? 0)
        .toDouble();

    // Status Logic
    bool isZeroStock = stock <= 0;
    bool isLowStock = !isZeroStock && stock <= minStock;
    bool isNearLowStock =
        !isZeroStock &&
        !isLowStock &&
        minStock > 0 &&
        stock <= (minStock * 1.25);

    // Filter lots to get count
    final lotsAsync = ref.watch(
      productLotsProvider(inventory.productId, inventory.warehouseId),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon / Image
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    image:
                        (variant.photoUrl ?? product.photoUrl) != null &&
                            (variant.photoUrl ?? product.photoUrl)!.isNotEmpty
                        ? DecorationImage(
                            image:
                                (variant.photoUrl ?? product.photoUrl)!
                                    .startsWith('http')
                                ? NetworkImage(
                                    (variant.photoUrl ?? product.photoUrl)!,
                                  )
                                : FileImage(
                                        File(
                                          (variant.photoUrl ??
                                              product.photoUrl)!,
                                        ),
                                      )
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      (variant.photoUrl ?? product.photoUrl) == null ||
                          (variant.photoUrl ?? product.photoUrl)!.isEmpty
                      ? Icon(
                          Icons.inventory_2_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Name Row (Now just Name)
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${variant.barcode ?? 'N/A'} • ${variant.variantName}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 3. Warehouse Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warehouse_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              warehouse?.name ?? 'Almacén Desconocido',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 4. Badges (Moved here)
                      if (isZeroStock || isLowStock || isNearLowStock) ...[
                        const SizedBox(height: 8),
                        if (isZeroStock)
                          _StatusBadge(
                            text: 'SIN STOCK',
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            bgColor: Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                          )
                        else if (isLowStock)
                          _StatusBadge(
                            text: 'BAJO STOCK',
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            bgColor: Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                          )
                        else if (isNearLowStock)
                          _StatusBadge(
                            text: 'CERCA DEL MÍNIMO',
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                            bgColor: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer,
                          ),
                      ],
                    ],
                  ),
                ),

                // Right Side Stats & Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Context Menu
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.more_horiz,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(context, ref);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar inventario',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Text(
                      stock % 1 == 0
                          ? stock.toInt().toString()
                          : stock.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isZeroStock || isLowStock
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    // Lots Count
                    lotsAsync.when(
                      data: (lots) {
                        // Filter lots for this VARIANT
                        final variantLots = lots
                            .where((l) => l.variantId == variant.id)
                            .toList();
                        final count = variantLots.length;
                        return Text(
                          'pzas | $count lotes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                      loading: () => Text(
                        'pzas | - lotes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      error: (_, __) => Text(
                        'pzas | ? lotes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
            height: 1,
          ),

          InkWell(
            onTap: () {
              // Pass IDs
              context.push(
                '/inventory/lots/${product.id}/${inventory.warehouseId}?variantId=${variant.id}',
                extra: {
                  'productName': '${product.name} - ${variant.variantName}',
                },
              );
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver Detalles de Lotes',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar inventario'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este registro de inventario?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        try {
          if (inventory.id != null) {
            await ref
                .read(inventoryProvider.notifier)
                .deleteInventory(inventory.id!);
          } else if (inventory.variantId != null) {
            await ref
                .read(inventoryProvider.notifier)
                .deleteInventoryByVariant(
                  inventory.productId,
                  inventory.warehouseId,
                  inventory.variantId!,
                );
          }
          // ScaffoldMessenger logic if needed
        } catch (e) {
          // Error handling
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
          }
        }
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bgColor;

  const _StatusBadge({
    required this.text,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
