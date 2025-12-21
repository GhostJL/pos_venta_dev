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
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
        if (constraints.maxWidth > 900) crossAxisCount = 3;

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  valueAsync.when(
                    data: (value) => Text(
                      isCurrency
                          ? currencyFormat.format(value)
                          : value.toString(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    loading: () => SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    ),
                    error: (_, __) => Text(
                      '--',
                      style: theme.textTheme.headlineSmall?.copyWith(
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (revenueAsync.isLoading || transactionsAsync.isLoading)
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  else if (revenueAsync.hasError || transactionsAsync.hasError)
                    Text(
                      '--',
                      style: theme.textTheme.headlineSmall?.copyWith(
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
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
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
