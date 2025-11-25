import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';

class ReturnsReportPage extends ConsumerStatefulWidget {
  const ReturnsReportPage({super.key});

  @override
  ConsumerState<ReturnsReportPage> createState() => _ReturnsReportPageState();
}

class _ReturnsReportPageState extends ConsumerState<ReturnsReportPage> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(returnsStatsProvider(_dateRange));
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Devoluciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (picked != null) {
                setState(() {
                  _dateRange = picked;
                });
              }
            },
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          final totalCount = stats['totalCount'] as int;
          final totalAmount = (stats['totalAmount'] as int) / 100.0;
          final byReason = stats['byReason'] as List<Map<String, Object?>>;
          final topProducts =
              stats['topProducts'] as List<Map<String, Object?>>;

          if (totalCount == 0) {
            return const Center(
              child: Text('No hay devoluciones en el período seleccionado'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Devoluciones',
                        value: totalCount.toString(),
                        icon: Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Monto Total',
                        value: currencyFormat.format(totalAmount),
                        icon: Icons.attach_money,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Top Products
                const Text(
                  'Productos Más Devueltos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topProducts.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final product = topProducts[index];
                      final name = product['product_name'] as String?;
                      final qty = product['total_quantity'] as double;
                      final amount = (product['total_amount'] as int) / 100.0;

                      // Calculate percentage relative to max amount for bar
                      double maxAmount = 0;
                      if (topProducts.isNotEmpty) {
                        maxAmount =
                            (topProducts.first['total_amount'] as int) / 100.0;
                      }
                      final percentage = maxAmount > 0
                          ? amount / maxAmount
                          : 0.0;

                      return ListTile(
                        title: Text(name ?? 'Producto Desconocido'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 4),
                            Text('${qty.toStringAsFixed(0)} unidades'),
                          ],
                        ),
                        trailing: Text(
                          currencyFormat.format(amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Returns by Reason
                const Text(
                  'Devoluciones por Motivo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: byReason.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final reasonData = byReason[index];
                      final reason = reasonData['reason'] as String;
                      final count = reasonData['count'] as int;
                      final amount =
                          (reasonData['total_amount'] as int) / 100.0;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getReasonColor(
                            reason,
                          ).withValues(alpha: 0.2),
                          child: Icon(
                            _getReasonIcon(reason),
                            color: _getReasonColor(reason),
                            size: 20,
                          ),
                        ),
                        title: Text(reason),
                        subtitle: Text('$count devoluciones'),
                        trailing: Text(
                          currencyFormat.format(amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Color _getReasonColor(String reason) {
    switch (reason.toLowerCase()) {
      case 'defectuoso':
        return Colors.red;
      case 'no deseado':
        return Colors.orange;
      case 'error en pedido':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getReasonIcon(String reason) {
    switch (reason.toLowerCase()) {
      case 'defectuoso':
        return Icons.broken_image;
      case 'no deseado':
        return Icons.thumb_down;
      case 'error en pedido':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
