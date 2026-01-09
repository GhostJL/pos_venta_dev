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
import 'package:posventa/presentation/providers/settings_provider.dart';

class InventoryHeader extends StatelessWidget {
  const InventoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 48 + 16), // Image space
          Expanded(
            flex: 3,
            child: _buildHeader(context, 'Producto / Variante'),
          ),
          Expanded(flex: 2, child: _buildHeader(context, 'Almacén')),
          Expanded(flex: 2, child: _buildHeader(context, 'Stock')),
          Expanded(flex: 1, child: _buildHeader(context, 'Estado')),
          const SizedBox(width: 48), // Actions space
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class InventoryTableRow extends ConsumerWidget {
  final Inventory inventory;
  final Product product;
  final ProductVariant variant;
  final Warehouse? warehouse;
  final bool hasAdjustAccess;

  const InventoryTableRow({
    super.key,
    required this.inventory,
    required this.product,
    required this.variant,
    this.warehouse,
    this.hasAdjustAccess = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Global Settings
    final settingsAsync = ref.watch(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;

    // Stock Logic
    final double stock = inventory.quantityOnHand;
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(
            '/inventory/lots/${product.id}/${inventory.warehouseId}?variantId=${variant.id}',
            extra: {'productName': '${product.name} - ${variant.variantName}'},
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildImage(variant.photoUrl ?? product.photoUrl),
              ),
              const SizedBox(width: 16),

              // Product / Variant / SKU
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${variant.variantName} • SKU: ${variant.barcode ?? 'N/A'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Warehouse
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(
                      Icons.warehouse_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        warehouse?.name ?? 'Desconocido',
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Stock
              Expanded(
                flex: 2,
                child: useInventory
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            stock % 1 == 0
                                ? stock.toInt().toString()
                                : stock.toStringAsFixed(2),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isZeroStock || isLowStock
                                  ? colorScheme.error
                                  : null,
                            ),
                          ),
                          lotsAsync.when(
                            data: (lots) {
                              final variantLots = lots
                                  .where((l) => l.variantId == variant.id)
                                  .toList();
                              return Text(
                                '${variantLots.length} lotes',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                            loading: () => const Text('-'),
                            error: (_, __) => const Text('-'),
                          ),
                        ],
                      )
                    : const Text('-'),
              ),

              // Status
              Expanded(
                flex: 1,
                child: useInventory
                    ? _buildStatusBadge(
                        context,
                        isZeroStock,
                        isLowStock,
                        isNearLowStock,
                      )
                    : const SizedBox(),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (value == 'delete' && hasAdjustAccess) {
                    _confirmDelete(context, ref, inventory, product.name);
                  }
                },
                itemBuilder: (context) => [
                  if (hasAdjustAccess)
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
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Center(child: Icon(Icons.inventory_2_outlined, size: 24));
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, size: 20)),
      );
    }
    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image, size: 20)),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    bool isZero,
    bool isLow,
    bool isNear,
  ) {
    final theme = Theme.of(context).colorScheme;
    if (isZero) {
      return _StatusChip(
        text: 'AGOTADO',
        color: theme.onErrorContainer,
        bgColor: theme.errorContainer,
      );
    }
    if (isLow) {
      return _StatusChip(
        text: 'BAJO',
        color: theme.onErrorContainer,
        bgColor: theme.errorContainer,
      );
    }
    if (isNear) {
      return _StatusChip(
        text: 'OPT',
        color: theme.onTertiaryContainer,
        bgColor: theme.tertiaryContainer,
      );
    }
    return _StatusChip(
      text: 'OK',
      color: theme.primary,
      bgColor: theme.primaryContainer,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Inventory item,
    String productName,
  ) async {
    // Reusing existing logic or implementing new dialog
    // The original card used a local _confirmDelete. We can duplicate or move to a mixin/util.
    // For simplicity, implementing inline basic dialog.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar inventario'),
        content: Text('¿Eliminar inventario de $productName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (item.id != null) {
        await ref.read(inventoryProvider.notifier).deleteInventory(item.id!);
      } else if (item.variantId != null) {
        await ref
            .read(inventoryProvider.notifier)
            .deleteInventoryByVariant(
              item.productId,
              item.warehouseId,
              item.variantId!,
            );
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final Color bgColor;

  const _StatusChip({
    required this.text,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
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
