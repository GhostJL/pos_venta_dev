import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/widgets/purchase/reception_item_card.dart';
import 'package:posventa/presentation/widgets/purchase/reception_summary_card.dart';

class PurchaseReceptionDialog extends StatefulWidget {
  final Purchase purchase;

  const PurchaseReceptionDialog({super.key, required this.purchase});

  @override
  State<PurchaseReceptionDialog> createState() =>
      _PurchaseReceptionDialogState();
}

class _PurchaseReceptionDialogState extends State<PurchaseReceptionDialog> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, double> _quantities = {};

  @override
  void initState() {
    super.initState();
    for (final item in widget.purchase.items) {
      final remaining = item.quantity - item.quantityReceived;
      final id = item.id;
      if (id != null && remaining > 0) {
        _quantities[id] = remaining;
        _controllers[id] = TextEditingController(
          text: _formatNumber(remaining),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _receiveAll() {
    setState(() {
      for (final item in widget.purchase.items) {
        final remaining = item.quantity - item.quantityReceived;
        final id = item.id;
        if (id != null && remaining > 0) {
          _quantities[id] = remaining;
          _controllers[id]?.text = _formatNumber(remaining);
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      for (final key in _quantities.keys) {
        _quantities[key] = 0;
        _controllers[key]?.text = '0';
      }
    });
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    double totalOrdered = 0;
    double totalReceived = 0;
    double totalPending = 0;

    for (final item in widget.purchase.items) {
      totalOrdered += item.quantity;
      totalReceived += item.quantityReceived;
      final remaining = item.quantity - item.quantityReceived;
      if (remaining > 0) {
        totalPending += _quantities[item.id] ?? 0;
      }
    }

    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.inventory_2, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recibir Mercancía',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Compra #${widget.purchase.purchaseNumber}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
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
              child: ListView.separated(
                itemCount: widget.purchase.items.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = widget.purchase.items[index];
                  final remaining = item.quantity - item.quantityReceived;
                  final id = item.id;

                  if (remaining <= 0) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.green.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
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
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }

                  return ReceptionItemCard(
                    item: item,
                    controller: _controllers[id]!,
                    onQuantityChanged: (qty) {
                      setState(() {
                        if (qty >= 0 && qty <= remaining) {
                          _quantities[id!] = qty;
                        }
                      });
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
                  final result = Map<int, double>.from(_quantities)
                    ..removeWhere((_, value) => value == 0);
                  context.pop(result);
                }
              : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
