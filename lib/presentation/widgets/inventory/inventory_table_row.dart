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
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/presentation/widgets/inventory/dialogs/inventory_adjustment_dialog.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/widgets/common/right_click_menu_wrapper.dart';

class InventoryTableRow extends ConsumerStatefulWidget {
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
  ConsumerState<InventoryTableRow> createState() => _InventoryTableRowState();
}

class _InventoryTableRowState extends ConsumerState<InventoryTableRow> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Global Settings
    final settingsAsync = ref.watch(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;

    // Stock Logic
    final double stock = widget.inventory.quantityOnHand;
    final double minStock =
        (widget.inventory.minStock ?? widget.variant.stockMin ?? 0).toDouble();

    // Status Logic
    bool isZeroStock = stock <= 0;
    bool isLowStock = !isZeroStock && stock <= minStock;
    bool isNearLowStock =
        !isZeroStock &&
        !isLowStock &&
        minStock > 0 &&
        stock <= (minStock * 1.25);

    // Filter lots to get count (Using availableLots to count only active ones)
    final lotsAsync = ref.watch(
      availableLotsProvider(
        widget.inventory.productId,
        widget.inventory.warehouseId,
      ),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double scale = _isHovering ? 1.01 : 1.0;
    final double elevation = _isHovering ? 2.0 : 0.0;

    final menuItems = <PopupMenuEntry<String>>[
      if (widget.hasAdjustAccess) ...[
        const PopupMenuItem(
          value: 'adjust',
          child: Row(
            children: [
              Icon(Icons.edit_note, size: 20),
              SizedBox(width: 8),
              Text('Ajustar Stock'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ];

    void onAction(String value) {
      if (value == 'delete' && widget.hasAdjustAccess) {
        _confirmDelete(context, ref, widget.inventory, widget.product.name);
      } else if (value == 'adjust' && widget.hasAdjustAccess) {
        _openAdjustmentDialog(context, ref, widget.inventory, widget.product);
      }
    }

    return RightClickMenuWrapper(
      menuItems: menuItems,
      onSelected: onAction,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(scale, scale, 1.0),
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: elevation,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            color: colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: _isHovering
                  ? BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    )
                  : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                context.push(
                  '/inventory/lots/${widget.product.id}/${widget.inventory.warehouseId}?variantId=${widget.variant.id}',
                  extra: {
                    'productName':
                        '${widget.product.name} - ${widget.variant.variantName}',
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                      child: _buildImage(
                        widget.variant.photoUrl ?? widget.product.photoUrl,
                      ),
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
                            widget.product.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.variant.variantName} • SKU: ${widget.variant.barcode ?? 'N/A'}',
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
                              widget.warehouse?.name ?? 'Desconocido',
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stock (Fixed Alignment)
                    Expanded(
                      flex: 2,
                      child: useInventory
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                                        .where(
                                          (l) =>
                                              l.variantId == widget.variant.id,
                                        )
                                        .toList();
                                    return Text(
                                      '${variantLots.length} lotes',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    );
                                  },
                                  loading: () => const Text('-'),
                                  error: (_, __) => const Text('-'),
                                ),
                              ],
                            )
                          : const Align(
                              alignment: Alignment.centerRight,
                              child: Text('-'),
                            ),
                    ),

                    // Status (Fixed Alignment)
                    Expanded(
                      flex: 2,
                      child: useInventory
                          ? Center(
                              child: _buildStatusBadge(
                                context,
                                isZeroStock,
                                isLowStock,
                                isNearLowStock,
                              ),
                            )
                          : const SizedBox(),
                    ),

                    // Actions (Fixed Width)
                    SizedBox(
                      width: 48,
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        onSelected: onAction,
                        itemBuilder: (context) => menuItems,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      color: theme.onPrimary,
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

  Future<void> _openAdjustmentDialog(
    BuildContext context,
    WidgetRef ref,
    Inventory inventory,
    Product product,
  ) async {
    final result = await InventoryAdjustmentDialog.show(
      context,
      productName: product.name,
      currentStock: inventory.quantityOnHand,
    );

    if (result != null) {
      final user = ref.read(authProvider).user;
      final userId = user?.id ?? 1;

      final movement = InventoryMovement(
        productId: inventory.productId,
        warehouseId: inventory.warehouseId,
        movementType: MovementType.adjustment,
        quantity: result.type == AdjustmentType.increment
            ? result.quantity
            : -result.quantity,
        quantityBefore: inventory.quantityOnHand,
        quantityAfter: result.type == AdjustmentType.increment
            ? inventory.quantityOnHand + result.quantity
            : inventory.quantityOnHand - result.quantity,
        referenceType: 'manual_adjustment',
        referenceId: 0,
        variantId: inventory.variantId,
        reason: result.reason,
        performedBy: userId,
        movementDate: DateTime.now(),
      );

      await ref.read(inventoryProvider.notifier).adjustInventory(movement);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Inventario actualizado')));
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
