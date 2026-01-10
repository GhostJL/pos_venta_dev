import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';

class CashierSessionMetrics extends ConsumerWidget {
  const CashierSessionMetrics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSessionAsync = ref.watch(currentCashSessionProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen de Sesión',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // NOTE: Using dynamic because build_runner failed to generate strict type for provider
          AsyncValueHandler(
            value: currentSessionAsync,
            data: (session) {
              if (session == null) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.no_meeting_room_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay sesión activa',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final detailAsync = ref.watch(cashSessionDetailProvider(session));

              return AsyncValueHandler(
                value: detailAsync,
                data: (detail) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmall = constraints.maxWidth < 600;
                      return Flex(
                        direction: isSmall ? Axis.vertical : Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MetricCard(
                            label: 'Apertura',
                            amount: detail.session.openingBalanceCents / 100,
                            icon: Icons.account_balance_wallet_outlined,
                            color: Colors.blue,
                            isSmall: isSmall,
                          ),
                          if (isSmall) const SizedBox(height: 16),
                          _MetricCard(
                            label: 'Ventas Totales',
                            amount: detail.totalGlobalSales / 100,
                            icon: Icons.point_of_sale_outlined,
                            color: Colors.green,
                            isSmall: isSmall,
                          ),
                          if (isSmall) const SizedBox(height: 16),
                          _MetricCard(
                            label: 'Efectivo en Caja',
                            amount: detail.expectedBalance / 100,
                            icon: Icons.savings_outlined,
                            color: Colors.orange,
                            isSmall: isSmall,
                          ),
                        ],
                      );
                    },
                  );
                },
                loadingWidget: const Center(child: CircularProgressIndicator()),
                errorBuilder: (e, st) => Text('Error al cargar métricas: $e'),
              );
            },
            loadingWidget: const Center(child: CircularProgressIndicator()),
            errorBuilder: (e, st) => Text('Error de sesión: $e'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final MaterialColor color;
  final bool isSmall;

  const _MetricCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Expanded(
      flex: isSmall ? 0 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color.shade700),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  currencyFormat.format(amount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
