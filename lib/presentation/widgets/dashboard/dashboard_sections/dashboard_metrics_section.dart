import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:intl/intl.dart';

class DashboardMetricsSection extends ConsumerWidget {
  const DashboardMetricsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysRevenueAsync = ref.watch(todaysRevenueProvider);
    final todaysTransactionsAsync = ref.watch(todaysTransactionsProvider);

    // Derived metric: Average Ticket
    double averageTicket = 0;

    // We can't easily calculate average ticket without raw numbers in sync,
    // but for now let's just display the main two.
    // Ideally we would return a single object with all stats to ensure consistency.

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt grid based on width
        int crossAxisCount = 1;
        if (constraints.maxWidth > 600) crossAxisCount = 2;
        if (constraints.maxWidth > 1000) crossAxisCount = 3;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildMetricCard(
              context,
              title: 'Ventas de Hoy',
              valueAsync: todaysRevenueAsync,
              icon: Icons.attach_money_rounded,
              color: Colors.green,
              isCurrency: true,
              width: _calculateCardWidth(constraints.maxWidth, crossAxisCount),
            ),
            _buildMetricCard(
              context,
              title: 'Transacciones',
              valueAsync: todaysTransactionsAsync,
              icon: Icons.receipt_long_rounded,
              color: Colors.blue,
              isCurrency: false,
              width: _calculateCardWidth(constraints.maxWidth, crossAxisCount),
            ),
            // Placeholder for Average Ticket or other metric
            _buildCalculatedMetricCard(
              context,
              title: 'Ticket Promedio',
              revenueAsync: todaysRevenueAsync,
              transactionsAsync: todaysTransactionsAsync,
              icon: Icons.pie_chart_rounded,
              color: Colors.orange,
              width: _calculateCardWidth(constraints.maxWidth, crossAxisCount),
            ),
          ],
        );
      },
    );
  }

  double _calculateCardWidth(double totalWidth, int count) {
    if (count <= 1) return double.infinity;
    // total width - (spacings * (count - 1)) / count
    return (totalWidth - (16 * (count - 1))) / count;
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required AsyncValue<num> valueAsync,
    required IconData icon,
    required Color color,
    required bool isCurrency,
    required double width,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(
                  30,
                ), // Slightly less transparent for better visibility
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  valueAsync.when(
                    data: (value) => Text(
                      isCurrency
                          ? currencyFormat.format(value)
                          : value.toString(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        // Increased size
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                    loading: () => SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: color,
                      ),
                    ),
                    error: (_, __) => Text(
                      '--',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.error,
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

  Widget _buildCalculatedMetricCard(
    BuildContext context, {
    required String title,
    required AsyncValue<double> revenueAsync,
    required AsyncValue<int> transactionsAsync,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (revenueAsync.isLoading || transactionsAsync.isLoading)
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: color,
                      ),
                    )
                  else if (revenueAsync.hasError || transactionsAsync.hasError)
                    Text(
                      '--',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.error,
                      ),
                    )
                  else
                    Builder(
                      builder: (context) {
                        final revenue = revenueAsync.asData?.value ?? 0;
                        final transactions =
                            transactionsAsync.asData?.value ?? 0;
                        final avg = transactions > 0
                            ? revenue / transactions
                            : 0;
                        return Text(
                          currencyFormat.format(avg),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -1.0,
                            height: 1.1,
                          ),
                        );
                      },
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
