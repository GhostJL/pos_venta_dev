import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/features/reports/domain/models/report_models.dart';
import 'package:posventa/features/reports/presentation/providers/reports_provider.dart';

import 'package:posventa/presentation/pages/shared/main_layout.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  void initState() {
    super.initState();
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
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Analíticas'),
        leading: isSmallScreen
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  MainLayout.of(context)?.openDrawer();
                },
                tooltip: 'Menú',
              )
            : null,
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
          : LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SummarySection(state: state, isMobile: isMobile),
                      const SizedBox(height: 24),
                      _SalesChart(state: state),
                      const SizedBox(height: 24),
                      _TopProductsSection(state: state, isMobile: isMobile),
                      const SizedBox(height: 24),
                      _PaymentBreakdownSection(
                        breakdown: state.paymentBreakdown,
                        isMobile: isMobile,
                      ),
                      const SizedBox(height: 24),
                      if (state.zReport != null)
                        _ZReportSection(
                          zReport: state.zReport!,
                          isMobile: isMobile,
                        ),
                      const SizedBox(height: 32), // Bottom padding
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final ReportsState state;
  final bool isMobile;

  const _SummarySection({required this.state, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final totalSales = state.dailySales.fold<double>(
      0,
      (sum, item) => sum + item.totalSales,
    );
    final totalTransactions = state.dailySales.fold<int>(
      0,
      (sum, item) => sum + item.transactionCount,
    );
    final totalProfit = state.dailySales.fold<double>(
      0,
      (sum, item) => sum + item.profit,
    );

    final cards = [
      _SummaryCard(
        title: 'Ventas Totales',
        value: currency.format(totalSales),
        icon: Icons.attach_money,
        color: Colors.green,
      ),
      if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 16),
      _SummaryCard(
        title: 'Transacciones',
        value: totalTransactions.toString(),
        icon: Icons.receipt,
        color: Colors.blue,
      ),
      if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 16),
      _SummaryCard(
        title: 'Ganancia Bruta',
        value: currency.format(totalProfit),
        icon: Icons.trending_up,
        color: Colors.orange,
      ),
    ];

    if (isMobile) {
      return Column(children: cards);
    } else {
      return Row(
        children: cards
            .map((c) => c is _SummaryCard ? Expanded(child: c) : c)
            .toList(),
      );
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
      elevation: 4, // Slightly higher elevation for better pop
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  final ReportsState state;

  const _SalesChart({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    if (state.dailySales.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No hay datos en este rango',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ventas Diarias', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.only(right: 16, top: 16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  state.dailySales
                      .map((e) => e.totalSales)
                      .reduce((a, b) => a > b ? a : b) *
                  1.2, // Add 20% buffer
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => theme.cardColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final day = state.dailySales[group.x];
                    return BarTooltipItem(
                      '${DateFormat('dd/MM').format(day.date)}\n',
                      theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: currency.format(day.totalSales),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < state.dailySales.length) {
                        final date = state.dailySales[value.toInt()].date;
                        // Avoid overcrowding on small screens: show labels sparsely if many days
                        if (state.dailySales.length > 7 &&
                            value.toInt() % 2 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Clean look
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: state.dailySales.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.totalSales,
                      color: theme.colorScheme.primary,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopProductsSection extends StatelessWidget {
  final ReportsState state;
  final bool isMobile;

  const _TopProductsSection({required this.state, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Productos Más Vendidos', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: isMobile
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.topProducts.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = state.topProducts[index];
                    return ListTile(
                      title: Text(
                        p.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Cant: ${p.quantitySold.toStringAsFixed(1)}',
                      ),
                      trailing: Text(
                        currency.format(p.totalRevenue),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                )
              : SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Producto')),
                      DataColumn(label: Text('Cantidad'), numeric: true),
                      DataColumn(label: Text('Ingresos'), numeric: true),
                    ],
                    rows: state.topProducts.map((p) {
                      return DataRow(
                        cells: [
                          DataCell(Text(p.productName)),
                          DataCell(Text(p.quantitySold.toStringAsFixed(1))),
                          DataCell(Text(currency.format(p.totalRevenue))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ZReportSection extends StatelessWidget {
  final ZReport zReport;
  final bool isMobile;

  const _ZReportSection({required this.zReport, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Corte Z (Resumen)', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _RowInfo('Ventas Totales', currency.format(zReport.totalSales)),
                _RowInfo('Impuestos', currency.format(zReport.totalTax)),
                _RowInfo('Transacciones', zReport.transactionCount.toString()),
                const Divider(height: 24),
                Text('Desglose por Pago', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...zReport.paymentMethodBreakdown.entries.map(
                  (e) => _RowInfo(e.key, currency.format(e.value)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentBreakdownSection extends StatelessWidget {
  final Map<String, double> breakdown;
  final bool isMobile;

  const _PaymentBreakdownSection({
    required this.breakdown,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    if (breakdown.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ventas por Método de Pago', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: breakdown.entries.map((e) {
                return Column(
                  children: [
                    _RowInfo(e.key, currency.format(e.value)),
                    if (e.key != breakdown.keys.last) const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
