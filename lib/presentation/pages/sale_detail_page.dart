import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class SaleDetailPage extends ConsumerWidget {
  final int saleId;

  const SaleDetailPage({super.key, required this.saleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de impresión próximamente'),
                ),
              );
            },
            tooltip: 'Imprimir Ticket',
          ),
        ],
      ),
      body: FutureBuilder<Sale?>(
        future: ref.read(getSaleByIdUseCaseProvider).call(saleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final sale = snapshot.data;
          if (sale == null) {
            return const Center(child: Text('Venta no encontrada'));
          }

          return _buildSaleDetail(context, ref, sale);
        },
      ),
    );
  }

  Widget _buildSaleDetail(BuildContext context, WidgetRef ref, Sale sale) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isCancelled = sale.status == SaleStatus.cancelled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale.saleNumber,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(sale.saleDate),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isCancelled
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCancelled ? 'CANCELADA' : 'COMPLETADA',
                          style: TextStyle(
                            color: isCancelled
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Cliente',
                    sale.customerName ?? 'Público General',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Almacén', 'Almacén #${sale.warehouseId}'),
                  if (isCancelled) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Motivo de Cancelación',
                      sale.cancellationReason ?? 'No especificado',
                      isError: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Items Section
          const Text(
            'Productos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...sale.items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName ?? 'Producto #${item.productId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          '\$${(item.totalCents / 100).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${item.quantity.toStringAsFixed(0)} x \$${(item.unitPriceCents / 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '= \$${(item.subtotalCents / 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (item.taxes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Impuestos aplicados:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...item.taxes.map(
                              (tax) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 18,
                                  top: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${tax.taxName} (${tax.taxRate.toStringAsFixed(2)}%)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      '\$${(tax.taxAmountCents / 100).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (item.taxCents > 0) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 18,
                                  top: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total impuestos:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    Text(
                                      '\$${(item.taxCents / 100).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Payments Section
          if (sale.payments.isNotEmpty) ...[
            const Text(
              'Pagos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...sale.payments.map(
              (payment) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _getPaymentIcon(payment.paymentMethod),
                    color: Colors.green.shade700,
                  ),
                  title: Text(payment.paymentMethod),
                  subtitle: Text(dateFormat.format(payment.paymentDate)),
                  trailing: Text(
                    '\$${(payment.amountCents / 100).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Totals Card
          Card(
            elevation: 2,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTotalRow('Subtotal', sale.subtotalCents / 100),
                  const SizedBox(height: 8),
                  _buildTotalRow('Impuestos', sale.taxCents / 100),
                  if (sale.discountCents > 0) ...[
                    const SizedBox(height: 8),
                    _buildTotalRow(
                      'Descuento',
                      sale.discountCents / 100,
                      isDiscount: true,
                    ),
                  ],
                  const Divider(height: 24),
                  _buildTotalRow(
                    'TOTAL',
                    sale.totalCents / 100,
                    isBold: true,
                    fontSize: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          if (!isCancelled) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showCancelDialog(context, ref, sale);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar Venta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isError ? Colors.red.shade700 : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 16,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: isDiscount ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'efectivo':
        return Icons.money;
      case 'tarjeta':
        return Icons.credit_card;
      case 'transferencia':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, Sale sale) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de que deseas cancelar esta venta?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes proporcionar un motivo'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final user = ref.read(authProvider).user;
                if (user == null) throw Exception('Usuario no autenticado');

                await ref
                    .read(cancelSaleUseCaseProvider)
                    .call(sale.id!, user.id!, reasonController.text.trim());

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Venta cancelada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop(); // Volver al historial
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }
}
