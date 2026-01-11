import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/features/reports/presentation/providers/reports_provider.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  void initState() {
    super.initState();
    // Load reports initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsProvider.notifier).loadReports();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final state = ref.read(reportsProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: state.startDate,
        end: state.endDate,
      ),
    );

    if (picked != null) {
      ref.read(reportsProvider.notifier).setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Analíticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Seleccionar Rango de Fechas',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reportsProvider.notifier).loadReports(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      _SummaryCard(
                        title: 'Ventas Totales',
                        value: currency.format(
                          state.dailySales.fold<double>(
                            0,
                            (sum, item) => sum + item.totalSales,
                          ),
                        ),
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _SummaryCard(
                        title: 'Transacciones',
                        value: state.dailySales
                            .fold<int>(
                              0,
                              (sum, item) => sum + item.transactionCount,
                            )
                            .toString(),
                        icon: Icons.receipt,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sales Chart Placeholder (If FL Chart not available, we show a list or basic bars)
                  Text('Ventas Diarias', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: state.dailySales.isEmpty
                        ? const Center(
                            child: Text('No hay datos en este rango'),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.dailySales.length,
                            itemBuilder: (context, index) {
                              final day = state.dailySales[index];
                              final maxSales = state.dailySales
                                  .map((e) => e.totalSales)
                                  .reduce((a, b) => a > b ? a : b);
                              final height =
                                  (day.totalSales /
                                      (maxSales == 0 ? 1 : maxSales)) *
                                  150;

                              return Container(
                                width: 50,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Tooltip(
                                      message: currency.format(day.totalSales),
                                      child: Container(
                                        height: height == 0 ? 2 : height,
                                        width: 30,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${day.date.day}/${day.date.month}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Top Products
                  Text(
                    'Productos Más Vendidos',
                    style: theme.textTheme.titleLarge,
                  ),
                  Card(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Producto')),
                        DataColumn(label: Text('Cantidad'), numeric: true),
                        DataColumn(label: Text('Ingresos'), numeric: true),
                      ],
                      rows: state.topProducts
                          .map(
                            (p) => DataRow(
                              cells: [
                                DataCell(Text(p.productName)),
                                DataCell(
                                  Text(p.quantitySold.toStringAsFixed(1)),
                                ),
                                DataCell(Text(currency.format(p.totalRevenue))),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Z-Report Section
                  if (state.zReport != null) ...[
                    Text(
                      'Corte Z (Hoy/Fin de Rango)',
                      style: theme.textTheme.titleLarge,
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _RowInfo(
                              'Ventas Totales',
                              currency.format(state.zReport!.totalSales),
                            ),
                            _RowInfo(
                              'Impuestos',
                              currency.format(state.zReport!.totalTax),
                            ),
                            _RowInfo(
                              'Transacciones',
                              state.zReport!.transactionCount.toString(),
                            ),
                            const Divider(),
                            Text(
                              'Desglose por Pago',
                              style: theme.textTheme.titleMedium,
                            ),
                            ...state.zReport!.paymentMethodBreakdown.entries
                                .map(
                                  (e) =>
                                      _RowInfo(e.key, currency.format(e.value)),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
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
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowInfo extends StatelessWidget {
  final String label;
  final String value;
  const _RowInfo(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
