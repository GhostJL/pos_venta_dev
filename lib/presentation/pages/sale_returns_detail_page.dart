import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:intl/intl.dart';

class SaleReturnsDetailPage extends ConsumerWidget {
  final int saleId;
  final Sale sale;

  const SaleReturnsDetailPage({
    super.key,
    required this.saleId,
    required this.sale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsAsync = ref.watch(saleReturnsForSaleProvider(saleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devoluciones'),
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
            tooltip: 'Imprimir',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de exportación próximamente'),
                ),
              );
            },
            tooltip: 'Exportar',
          ),
        ],
      ),
      body: returnsAsync.when(
        data: (returns) {
          if (returns.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay devoluciones',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final totalReturnedCents = returns.fold<int>(
            0,
            (sum, r) => sum + r.totalCents,
          );
          final netTotalCents = sale.totalCents - totalReturnedCents;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Summary Card
                _buildHeaderCard(
                  context,
                  returns,
                  totalReturnedCents,
                  netTotalCents,
                ),
                const SizedBox(height: 24),

                // Returns List
                Row(
                  children: [
                    Icon(
                      Icons.keyboard_return,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Historial de Devoluciones',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ...returns.map(
                  (returnItem) => _buildReturnCard(context, returnItem),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    List<SaleReturn> returns,
    int totalReturnedCents,
    int netTotalCents,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta ${sale.saleNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(sale.saleDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildSummaryRow(
              'Total Original',
              '\$${(sale.totalCents / 100).toStringAsFixed(2)}',
              Colors.grey.shade700,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Total Devuelto (${returns.length} ${returns.length == 1 ? 'devolución' : 'devoluciones'})',
              '-\$${(totalReturnedCents / 100).toStringAsFixed(2)}',
              Colors.red.shade700,
              isBold: true,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total Neto',
              '\$${(netTotalCents / 100).toStringAsFixed(2)}',
              Colors.blue.shade900,
              isBold: true,
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildReturnCard(BuildContext context, SaleReturn returnItem) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200, width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: Colors.orange.shade900,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        returnItem.returnNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '-\$${(returnItem.totalCents / 100).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Time
                  _buildInfoRow(
                    Icons.access_time,
                    'Fecha y Hora',
                    dateFormat.format(returnItem.returnDate),
                    Colors.blue.shade700,
                  ),
                  const SizedBox(height: 12),

                  // Processed By
                  _buildInfoRow(
                    Icons.person,
                    'Procesado por',
                    returnItem.processedByName ??
                        'Usuario #${returnItem.processedBy}',
                    Colors.purple.shade700,
                  ),
                  const SizedBox(height: 12),

                  // Refund Method
                  _buildInfoRow(
                    _getRefundMethodIcon(returnItem.refundMethod),
                    'Método de Reembolso',
                    returnItem.refundMethod.displayName,
                    Colors.green.shade700,
                  ),
                  const SizedBox(height: 12),

                  // General Reason
                  _buildInfoRow(
                    Icons.info_outline,
                    'Motivo General',
                    returnItem.reason,
                    Colors.orange.shade700,
                  ),

                  // Products Section
                  if (returnItem.items.isNotEmpty) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Productos Devueltos',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...returnItem.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.productName ??
                                          'Producto #${item.productId}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '-\$${(item.totalCents / 100).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Cantidad: ${item.quantity.toStringAsFixed(0)} x \$${(item.unitPriceCents / 100).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (item.reason != null &&
                                  item.reason!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.label_outline,
                                      size: 14,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Motivo: ${item.reason}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Notes
                  if (returnItem.notes != null &&
                      returnItem.notes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notas Adicionales',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  returnItem.notes!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getRefundMethodIcon(RefundMethod method) {
    switch (method) {
      case RefundMethod.cash:
        return Icons.money;
      case RefundMethod.card:
        return Icons.credit_card;
      case RefundMethod.credit:
        return Icons.account_balance_wallet;
    }
  }
}
