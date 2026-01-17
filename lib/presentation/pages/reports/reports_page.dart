import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/report_models.dart';
import 'package:posventa/presentation/providers/reports_provider.dart';

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
                      if (state.lowStockItems.isNotEmpty) ...[
                        _LowStockSection(
                          items: state.lowStockItems,
                          isMobile: isMobile,
                        ),
                        const SizedBox(height: 24),
                      ],
                      _SalesChart(state: state),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: isMobile ? 1 : 3,
                            child: _TopProductsSection(
                              state: state,
                              isMobile: isMobile,
                            ),
                          ),
                          if (!isMobile) const SizedBox(width: 24),
                          if (!isMobile)
                            Expanded(
                              flex: 2,
                              child: _PaymentBreakdownSection(
                                breakdown: state.paymentBreakdown,
                                isMobile: isMobile,
                              ),
                            ),
                        ],
                      ),
                      if (isMobile) ...[
                        const SizedBox(height: 24),
                        _PaymentBreakdownSection(
                          breakdown: state.paymentBreakdown,
                          isMobile: isMobile,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (state.zReport != null)
                        _ZReportSection(
                          zReport: state.zReport!,
                          isMobile: isMobile,
                        ),
                      const SizedBox(height: 32),
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
      _SummaryCard(
        title: 'Transacciones',
        value: totalTransactions.toString(),
        icon: Icons.receipt,
        color: Colors.blue,
      ),
      _SummaryCard(
        title: 'Ganancia Bruta',
        value: currency.format(totalProfit),
        icon: Icons.trending_up,
        color: Colors.orange,
      ),
      _SummaryCard(
        title: 'Valor Inventario',
        value: currency.format(state.inventoryValue),
        icon: Icons.inventory,
        color: Colors.purple,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(width: double.infinity, child: c),
              ),
            )
            .toList(),
      );
    } else {
      return Row(
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: c,
                ),
              ),
            )
            .toList(),
      );
    }
  }
}

class _LowStockSection extends StatelessWidget {
  final List<LowStockItem> items;
  final bool isMobile;

  const _LowStockSection({required this.items, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayItems = items.take(10).toList();

    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Alerta de Stock Bajo (${items.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.go('/inventory'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: const Text('Ver Inventario'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName),
                  subtitle: Text(
                    '${item.variantName} • ${item.warehouseName ?? "Almacén General"}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.quantityOnHand.toStringAsFixed(1)} / ${item.minStock.toStringAsFixed(1)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (items.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    '+ ${items.length - 10} productos más...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
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
    return Card(
      elevation: 2,
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
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
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
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tendencia de Ventas', style: theme.textTheme.titleMedium),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      state.dailySales
                          .map((e) => e.totalSales)
                          .fold(0.0, (p, c) => p > c ? p : c) *
                      1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => theme.cardColor,
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
                            if (state.dailySales.length > 10 &&
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
                      sideTitles: SideTitles(showTitles: false),
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
        ),
      ),
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
    final displayItems = state.topProducts.take(10).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Top Productos', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.go('/products'),
                  child: const Text('Ver Catálogo'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = displayItems[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    p.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${p.quantitySold.toStringAsFixed(0)} vend.),',
                  ),
                  trailing: Text(
                    currency.format(p.totalRevenue),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
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

class _PaymentBreakdownSection extends StatefulWidget {
  final Map<String, double> breakdown;
  final bool isMobile;

  const _PaymentBreakdownSection({
    required this.breakdown,
    required this.isMobile,
  });

  @override
  State<_PaymentBreakdownSection> createState() =>
      _PaymentBreakdownSectionState();
}

class _PaymentBreakdownSectionState extends State<_PaymentBreakdownSection> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    if (widget.breakdown.isEmpty) return const SizedBox.shrink();

    final total = widget.breakdown.values.fold(0.0, (sum, val) => sum + val);
    final keys = widget.breakdown.keys.toList();
    // Default colors for chart
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Métodos de Pago', style: theme.textTheme.titleMedium),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: List.generate(widget.breakdown.length, (i) {
                    final isTouched = i == touchedIndex;
                    final fontSize = isTouched ? 16.0 : 12.0;
                    final radius = isTouched ? 60.0 : 50.0;
                    final value = widget.breakdown[keys[i]]!;
                    final percentage = (value / total * 100);

                    return PieChartSectionData(
                      color: colors[i % colors.length],
                      value: value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: radius,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: List.generate(widget.breakdown.length, (i) {
                final key = keys[i];
                final value = widget.breakdown[key]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors[i % colors.length],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(key),
                        ],
                      ),
                      Text(
                        currency.format(value),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
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
