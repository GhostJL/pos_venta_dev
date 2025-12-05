import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_reception_item.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/widgets/purchases/reception/reception_item_card.dart';
import 'package:posventa/presentation/widgets/purchases/reception/reception_summary_card.dart';

class PurchaseReceptionDialog extends ConsumerStatefulWidget {
  final Purchase purchase;

  const PurchaseReceptionDialog({super.key, required this.purchase});

  @override
  ConsumerState<PurchaseReceptionDialog> createState() =>
      _PurchaseReceptionDialogState();
}

class _ReceptionItemState {
  final TextEditingController quantityController;
  final TextEditingController lotController;
  final TextEditingController expirationController;
  double quantity;
  DateTime? expirationDate;

  _ReceptionItemState({required double initialQuantity})
    : quantityController = TextEditingController(
        text: initialQuantity.toStringAsFixed(initialQuantity % 1 == 0 ? 0 : 2),
      ),
      lotController = TextEditingController(),
      expirationController = TextEditingController(),
      quantity = initialQuantity;

  void dispose() {
    quantityController.dispose();
    lotController.dispose();
    expirationController.dispose();
  }
}

class _PurchaseReceptionDialogState
    extends ConsumerState<PurchaseReceptionDialog> {
  final Map<int, _ReceptionItemState> _itemStates = {};

  @override
  void initState() {
    super.initState();
    for (final item in widget.purchase.items) {
      final remaining = item.quantity - item.quantityReceived;
      final id = item.id;
      if (id != null && remaining > 0) {
        _itemStates[id] = _ReceptionItemState(initialQuantity: remaining);
      }
    }
  }

  @override
  void dispose() {
    for (final state in _itemStates.values) {
      state.dispose();
    }
    super.dispose();
  }

  void _receiveAll() {
    setState(() {
      for (final item in widget.purchase.items) {
        final remaining = item.quantity - item.quantityReceived;
        final id = item.id;
        if (id != null && remaining > 0) {
          final state = _itemStates[id];
          if (state != null) {
            state.quantity = remaining;
            state.quantityController.text = _formatNumber(remaining);
          }
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      for (final state in _itemStates.values) {
        state.quantity = 0;
        state.quantityController.text = '0';
      }
    });
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  }

  Future<void> _selectDate(
    BuildContext context,
    _ReceptionItemState state,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != state.expirationDate) {
      setState(() {
        state.expirationDate = picked;
        state.expirationController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);

    double totalOrdered = 0;
    double totalReceived = 0;
    double totalPending = 0;

    for (final item in widget.purchase.items) {
      totalOrdered += item.quantity;
      totalReceived += item.quantityReceived;
      final remaining = item.quantity - item.quantityReceived;
      if (remaining > 0) {
        totalPending += _itemStates[item.id]?.quantity ?? 0;
      }
    }

    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.inventory_2, color: AppTheme.alertInfo),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recibir Mercancía',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Compra #${widget.purchase.purchaseNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: maxHeight,
        child: Column(
          children: [
            /// Bloque resumen
            ReceptionSummaryCard(
              totalOrdered: totalOrdered,
              totalReceived: totalReceived,
              totalPending: totalPending,
            ),

            /// Acciones rápidas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Limpiar',
                ),
                FilledButton.icon(
                  onPressed: _receiveAll,
                  icon: const Icon(Icons.done_all),
                  label: const Text('Recibir Todo'),
                ),
              ],
            ),

            /// Lista con scroll independiente
            Expanded(
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (products) {
                  final productMap = {for (var p in products) p.id!: p};

                  return ListView.separated(
                    itemCount: widget.purchase.items.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Theme.of(context).colorScheme.outline),
                    itemBuilder: (context, index) {
                      final item = widget.purchase.items[index];
                      final remaining = item.quantity - item.quantityReceived;
                      final id = item.id;
                      final product = productMap[item.productId];
                      final variant = product?.variants
                          ?.where((v) => v.id == item.variantId)
                          .firstOrNull;

                      if (remaining <= 0) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: AppTheme.transactionSuccess,
                            ),
                            title: Text(
                              item.productName ?? 'Producto',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              'Completamente recibido: ${_formatNumber(item.quantity)} ${item.unitOfMeasure}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }

                      final state = _itemStates[id];
                      if (state == null) return const SizedBox.shrink();

                      return ReceptionItemCard(
                        item: item,
                        product: product,
                        variant: variant,
                        quantityController: state.quantityController,
                        lotController: state.lotController,
                        expirationController: state.expirationController,
                        onQuantityChanged: (qty) {
                          setState(() {
                            if (qty >= 0 && qty <= remaining) {
                              state.quantity = qty;
                            }
                          });
                        },
                        onExpirationTap: () => _selectDate(context, state),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: totalPending > 0
              ? () {
                  final List<PurchaseReceptionItem> result = [];
                  _itemStates.forEach((itemId, state) {
                    if (state.quantity > 0) {
                      String lot = state.lotController.text.trim();
                      if (lot.isEmpty) {
                        final now = DateTime.now();
                        final dateStr = now
                            .toIso8601String()
                            .substring(0, 10)
                            .replaceAll('-', '');
                        final timeStr = now
                            .toIso8601String()
                            .substring(11, 19)
                            .replaceAll(':', '');
                        lot = 'LOT-$dateStr-$timeStr';
                      }

                      result.add(
                        PurchaseReceptionItem(
                          itemId: itemId,
                          quantity: state.quantity,
                          lotNumber: lot,
                          expirationDate: state.expirationDate,
                        ),
                      );
                    }
                  });
                  context.pop(result);
                }
              : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
