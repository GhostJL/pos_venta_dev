import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Está seguro de cancelar la compra #${purchase.purchaseNumber}?',
            ),
            if (purchase.status == PurchaseStatus.partial ||
                purchase.status == PurchaseStatus.completed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta compra tiene items recibidos. Al cancelar, se revertirá el inventario recibido.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Salir'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.cancel),
            label: const Text('Sí, Cancelar'),
          ),
        ],
      ),
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
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Compra \n#${purchase.purchaseNumber}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      _buildStatusBadge(purchase.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Proveedor:', purchase.supplierName ?? 'N/A'),
                  _buildInfoRow(
                    'Fecha:',
                    dateFormat.format(purchase.purchaseDate),
                  ),
                  if (purchase.supplierInvoiceNumber != null)
                    _buildInfoRow(
                      'Factura Prov.:',
                      purchase.supplierInvoiceNumber!,
                    ),
                  if (purchase.receivedDate != null)
                    _buildInfoRow(
                      'Última Recepción:',
                      dateFormat.format(purchase.receivedDate!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Productos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: purchase.items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return _PurchaseItemTile(item: purchase.items[index]);
            },
          ),

          const SizedBox(height: 24),

          // Totals
          Card(
            color: Theme.of(context).colorScheme.surface.withAlpha(100),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTotalRow('Subtotal', purchase.subtotalCents),
                  _buildTotalRow('Impuestos', purchase.taxCents),
                  const Divider(),
                  _buildTotalRow('Total', purchase.totalCents, isTotal: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PurchaseStatus status) {
    Color color;
    String text;
    switch (status) {
      case PurchaseStatus.pending:
        color = Colors.orange;
        text = 'PENDIENTE';
        break;
      case PurchaseStatus.completed:
        color = Colors.green;
        text = 'COMPLETADA';
        break;
      case PurchaseStatus.cancelled:
        color = Colors.red;
        text = 'CANCELADA';
        break;
      case PurchaseStatus.partial:
        color = Colors.blue;
        text = 'PARCIAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, int cents, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            '\$${(cents / 100).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseItemTile extends StatelessWidget {
  final PurchaseItem item;

  const _PurchaseItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isFullyReceived = item.quantityReceived >= item.quantity;
    final isPartiallyReceived =
        item.quantityReceived > 0 && item.quantityReceived < item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Producto #${item.productId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${item.quantity} ${item.unitOfMeasure} x \$${(item.unitCostCents / 100).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (item.quantityReceived > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          isFullyReceived
                              ? Icons.check_circle
                              : Icons.timelapse,
                          size: 14,
                          color: isFullyReceived ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Recibido: ${item.quantityReceived} / ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isFullyReceived
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '\$${(item.totalCents / 100).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
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
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pedido:'),
                        Text(
                          '${totalOrdered.toStringAsFixed(totalOrdered % 1 == 0 ? 0 : 2)} unidades',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ya Recibido:'),
                        Text(
                          '${totalReceived.toStringAsFixed(totalReceived % 1 == 0 ? 0 : 2)} unidades',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('A Recibir Ahora:'),
                        Text(
                          '${totalPending.toStringAsFixed(totalPending % 1 == 0 ? 0 : 2)} unidades',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Limpiar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _receiveAll,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Recibir Todo'),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.purchase.items.length,
                itemBuilder: (context, index) {
                  final item = widget.purchase.items[index];
                  final remaining = item.quantity - item.quantityReceived;

                  if (remaining <= 0) return const SizedBox.shrink();

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                      'Pedido:',
                                      '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 2)} ${item.unitOfMeasure}',
                                      Colors.grey.shade700,
                                    ),
                                    if (item.quantityReceived > 0) ...[
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                        'Recibido:',
                                        '${item.quantityReceived.toStringAsFixed(item.quantityReceived % 1 == 0 ? 0 : 2)} ${item.unitOfMeasure}',
                                        Colors.green.shade700,
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    _buildInfoRow(
                                      'Pendiente:',
                                      '${remaining.toStringAsFixed(remaining % 1 == 0 ? 0 : 2)} ${item.unitOfMeasure}',
                                      Colors.orange.shade700,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _controllers[item.id],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: 'Recibir',
                                    suffixText: item.unitOfMeasure,
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    final qty = double.tryParse(value) ?? 0;
                                    setState(() {
                                      _quantities[item.id!] = qty;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Validate
            bool hasError = false;
            for (final item in widget.purchase.items) {
              final remaining = item.quantity - item.quantityReceived;
              final toReceive = _quantities[item.id!] ?? 0;
              if (toReceive > remaining) {
                hasError = true;
                break;
              }
            }

            if (hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No puedes recibir más de lo pendiente'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Filter out 0s
            final result = Map<int, double>.from(_quantities)
              ..removeWhere((key, value) => value <= 0);

            if (result.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Debes recibir al menos un producto'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            Navigator.pop(context, result);
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Confirmar Recepción'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
