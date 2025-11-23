import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_cancel_dialog.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_info_card.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_items_list.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_totals_card.dart';
import 'package:posventa/presentation/widgets/purchase/reception_summary_card.dart';
import 'package:posventa/presentation/widgets/purchase/reception_item_card.dart';

class PurchaseDetailPage extends ConsumerWidget {
  final int purchaseId;

  const PurchaseDetailPage({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseAsync = ref.watch(purchaseByIdProvider(purchaseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Compra'),
        actions: [
          // Show receive button only for pending or partial purchases
          purchaseAsync.when(
            data: (purchase) {
              if (purchase == null) return const SizedBox.shrink();

              final canReceive =
                  purchase.status == PurchaseStatus.pending ||
                  purchase.status == PurchaseStatus.partial;

              final canCancel = purchase.status != PurchaseStatus.cancelled;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canReceive)
                    IconButton(
                      icon: const Icon(Icons.check_circle),
                      tooltip: 'Recibir Compra',
                      onPressed: () => _receivePurchase(context, ref, purchase),
                    ),
                  if (canCancel)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'cancel') {
                          _cancelPurchase(context, ref, purchase);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Cancelar Compra',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: purchaseAsync.when(
        data: (purchase) {
          if (purchase == null) {
            return const Center(child: Text('Compra no encontrada'));
          }
          return _PurchaseDetailContent(purchase: purchase);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _cancelPurchase(
    BuildContext context,
    WidgetRef ref,
    Purchase purchase,
  ) async {
    final confirmed = await PurchaseCancelDialog.show(
      context: context,
      purchase: purchase,
    );

    if (confirmed != true) return;

    try {
      final user = ref.read(authProvider).user;
      if (user == null) throw Exception('Usuario no autenticado');

      await ref
          .read(purchaseProvider.notifier)
          .cancelPurchase(purchase.id!, user.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _receivePurchase(
    BuildContext context,
    WidgetRef ref,
    Purchase purchase,
  ) async {
    // Show partial reception dialog
    final receivedQuantities = await showDialog<Map<int, double>>(
      context: context,
      builder: (context) => PurchaseReceptionDialog(purchase: purchase),
    );

    if (receivedQuantities == null || receivedQuantities.isEmpty) return;

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await ref
          .read(purchaseProvider.notifier)
          .receivePurchase(purchase.id!, receivedQuantities, user.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Recepción registrada exitosamente')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al recibir compra: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

class _PurchaseDetailContent extends StatelessWidget {
  final Purchase purchase;

  const _PurchaseDetailContent({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          PurchaseInfoCard(purchase: purchase),
          const SizedBox(height: 24),

          Text('Productos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Items List
          PurchaseItemsList(items: purchase.items),

          const SizedBox(height: 24),

          // Totals
          PurchaseTotalsCard(
            subtotalCents: purchase.subtotalCents,
            taxCents: purchase.taxCents,
            totalCents: purchase.totalCents,
          ),
        ],
      ),
    );
  }
}

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
      if (remaining > 0) {
        _quantities[item.id!] = remaining;
        _controllers[item.id!] = TextEditingController(
          text: remaining.toStringAsFixed(remaining % 1 == 0 ? 0 : 2),
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
        if (remaining > 0) {
          _quantities[item.id!] = remaining;
          _controllers[item.id!]?.text = remaining.toStringAsFixed(
            remaining % 1 == 0 ? 0 : 2,
          );
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

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    double totalOrdered = 0;
    double totalReceived = 0;
    double totalPending = 0;

    for (final item in widget.purchase.items) {
      totalOrdered += item.quantity;
      totalReceived += item.quantityReceived;
      final remaining = item.quantity - item.quantityReceived;
      if (remaining > 0) {
        totalPending += _quantities[item.id!] ?? 0;
      }
    }

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.inventory_2, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recibir Mercancía'),
                Text(
                  'Compra #${widget.purchase.purchaseNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary Card
            ReceptionSummaryCard(
              totalOrdered: totalOrdered,
              totalReceived: totalReceived,
              totalPending: totalPending,
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpiar'),
                ),
                ElevatedButton.icon(
                  onPressed: _receiveAll,
                  icon: const Icon(Icons.done_all),
                  label: const Text('Recibir Todo'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Items List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.purchase.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = widget.purchase.items[index];
                  final remaining = item.quantity - item.quantityReceived;

                  if (remaining <= 0) {
                    // Item fully received - show read-only card
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName ?? 'Producto',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Completamente recibido: ${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 2)} ${item.unitOfMeasure}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ReceptionItemCard(
                    item: item,
                    controller: _controllers[item.id!]!,
                    onQuantityChanged: (qty) {
                      setState(() {
                        if (qty >= 0 && qty <= remaining) {
                          _quantities[item.id!] = qty;
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
        ElevatedButton(
          onPressed: totalPending > 0
              ? () {
                  final result = Map<int, double>.from(_quantities);
                  result.removeWhere((key, value) => value == 0);
                  context.pop(result);
                }
              : null,
          child: const Text('Confirmar Recepción'),
        ),
      ],
    );
  }
}
