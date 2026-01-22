import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/return_reason.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';

class ReturnItemsSelector extends ConsumerStatefulWidget {
  const ReturnItemsSelector({super.key});

  @override
  ConsumerState<ReturnItemsSelector> createState() =>
      _ReturnItemsSelectorState();
}

class _ReturnItemsSelectorState extends ConsumerState<ReturnItemsSelector> {
  final Map<int, TextEditingController> _quantityControllers = {};
  final Map<int, TextEditingController> _reasonControllers = {};

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (var controller in _reasonControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(returnProcessingProvider);
    final sale = state.selectedSale;

    if (sale == null || sale.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_shopping_cart_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay productos en esta venta',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<Map<int, double>>(
      future: ref
          .read(saleReturnRepositoryProvider)
          .getReturnedQuantities(sale.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final returnedQty = snapshot.data!;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sale.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = sale.items[index];
            final alreadyReturned = returnedQty[item.id] ?? 0.0;
            final maxQuantity = item.quantity - alreadyReturned;

            if (maxQuantity <= 0) {
              return _buildFullyReturnedItem(item);
            }

            return _buildReturnableItem(item, maxQuantity, state);
          },
        );
      },
    );
  }

  Widget _buildFullyReturnedItem(SaleItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.outlineVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: cs.outline,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.variantName != null
                      ? '${item.productName} - ${item.variantName}'
                      : item.productName ?? 'Producto #${item.productId}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    decoration: TextDecoration.lineThrough,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Completamente devuelto',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: cs.primary.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildReturnableItem(
    SaleItem item,
    double maxQuantity,
    ReturnProcessingState state,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSelected = state.selectedItems.containsKey(item.id);
    final itemData = state.selectedItems[item.id];

    // Initialize controllers if needed
    if (!_quantityControllers.containsKey(item.id!)) {
      _quantityControllers[item.id!] = TextEditingController(
        text: maxQuantity.toString(),
      );
    }
    if (!_reasonControllers.containsKey(item.id!)) {
      _reasonControllers[item.id!] = TextEditingController();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? cs.primaryContainer.withValues(alpha: 0.1)
            : cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? cs.primary
              : cs.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              ref
                  .read(returnProcessingProvider.notifier)
                  .toggleItem(item, !isSelected, maxQuantity);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      ref
                          .read(returnProcessingProvider.notifier)
                          .toggleItem(item, value ?? false, maxQuantity);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product Icon/Thumbnail placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: cs.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.variantName != null
                              ? '${item.productName} - ${item.variantName}'
                              : item.productName ??
                                    'Producto #${item.productId}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Disponible: ${maxQuantity.toStringAsFixed(maxQuantity % 1 == 0 ? 0 : 2)} ${item.unitOfMeasure}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (item.discountCents > 0) ...[
                        Text(
                          '\$${item.unitPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          '\$${((item.unitPriceCents - (item.discountCents / item.quantity)) / 100.0).toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ] else
                        Text(
                          '\$${item.unitPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      Text(
                        'Unitario',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.outline,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded Edit Section
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: isSelected
                ? Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quantity Input with buttons
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cantidad a devolver',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _quantityControllers[item.id],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      fillColor: cs.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: cs.outlineVariant,
                                        ),
                                      ),
                                      suffixText: item.unitOfMeasure,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      final qty = double.tryParse(value);
                                      if (qty != null) {
                                        ref
                                            .read(
                                              returnProcessingProvider.notifier,
                                            )
                                            .updateItemQuantity(item.id!, qty);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Reason Selector
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Motivo',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<ReturnReason>(
                                    isExpanded: true,
                                    initialValue: itemData?.reason != null
                                        ? ReturnReason.values.firstWhere(
                                            (e) => e.label == itemData?.reason,
                                            orElse: () => ReturnReason.other,
                                          )
                                        : null,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      fillColor: cs.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: cs.outlineVariant,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                    items: ReturnReason.values.map((reason) {
                                      return DropdownMenuItem(
                                        value: reason,
                                        child: Text(
                                          reason.label,
                                          style: theme.textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        ref
                                            .read(
                                              returnProcessingProvider.notifier,
                                            )
                                            .updateItemReason(
                                              item.id!,
                                              value.label,
                                            );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (itemData != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calculate_outlined,
                                      size: 16,
                                      color: cs.onSecondaryContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Reembolso estimado:',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: cs.onSecondaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${(itemData.totalCents / 100.0).toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: cs.onSecondaryContainer,
                                    fontWeight: FontWeight.w900,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
