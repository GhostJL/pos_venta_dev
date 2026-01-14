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
      return const Center(child: Text('No hay productos en esta venta'));
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

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sale.items.length,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.outline,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'Producto #${item.productId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Ya devuelto completamente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnableItem(
    SaleItem item,
    double maxQuantity,
    ReturnProcessingState state,
  ) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
      ),
      child: InkWell(
        onTap: () {
          ref
              .read(returnProcessingProvider.notifier)
              .toggleItem(item, !isSelected, maxQuantity);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName ?? 'Producto #${item.productId}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Disponible: ${maxQuantity.toStringAsFixed(maxQuantity % 1 == 0 ? 0 : 2)} ${item.unitOfMeasure}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isSelected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              height: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _quantityControllers[item.id],
                                  decoration: InputDecoration(
                                    labelText: 'Cantidad',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixText: item.unitOfMeasure,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
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
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Requerido';
                                    }
                                    final qty = double.tryParse(value);
                                    if (qty == null) return 'Inválido';
                                    if (qty <= 0) return '> 0';
                                    if (qty > maxQuantity) {
                                      return 'Max: $maxQuantity';
                                    }
                                    return null;
                                  },
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
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<ReturnReason>(
                                  isExpanded: true,
                                  initialValue: itemData?.reason != null
                                      ? ReturnReason.values.firstWhere(
                                          (e) => e.label == itemData?.reason,
                                          orElse: () => ReturnReason.other,
                                        )
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: 'Motivo',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                  ),
                                  items: ReturnReason.values.map((reason) {
                                    return DropdownMenuItem(
                                      value: reason,
                                      child: Text(
                                        reason.label,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      _reasonControllers[item.id]?.text =
                                          value.label;
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
                              ),
                            ],
                          ),
                          if (itemData != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal a devolver:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '\$${(itemData.totalCents / 100.0).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
