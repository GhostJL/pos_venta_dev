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
          // Show receive button only for pending purchases
          purchaseAsync.when(
            data: (purchase) {
              if (purchase != null &&
                  purchase.status == PurchaseStatus.pending) {
                return IconButton(
                  icon: const Icon(Icons.check_circle),
                  tooltip: 'Recibir Compra',
                  onPressed: () => _receivePurchase(context, ref, purchase),
                );
              }
              return const SizedBox.shrink();
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

  Future<void> _receivePurchase(
    BuildContext context,
    WidgetRef ref,
    Purchase purchase,
  ) async {
    // Confirm reception
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recibir Compra'),
        content: Text(
          '¿Confirma que ha recibido la mercancía de la compra ${purchase.purchaseNumber}?\n\n'
          'Esta acción:\n'
          '• Actualizará el inventario\n'
          '• Registrará movimientos en el Kardex\n'
          '• Actualizará los costos de los productos',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar Recepción'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await ref
          .read(purchaseProvider.notifier)
          .receivePurchase(purchase.id!, user.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra recibida exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al recibir compra: $e'),
            backgroundColor: Colors.red,
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
                      'Recibido:',
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
