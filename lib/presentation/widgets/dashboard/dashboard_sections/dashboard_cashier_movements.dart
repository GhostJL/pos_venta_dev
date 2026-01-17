import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:posventa/presentation/widgets/cash_sessions/detail/manual_movements_card.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';

class DashboardCashierMovements extends ConsumerWidget {
  const DashboardCashierMovements({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSessionAsync = ref.watch(currentCashSessionProvider);
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final theme = Theme.of(context);

    return AsyncValueHandler<CashSession?>(
      value: currentSessionAsync,
      data: (session) {
        if (session == null) {
          return const SizedBox.shrink();
        }

        final detailAsync = ref.watch(cashSessionDetailProvider(session));

        return Container(
          height: 400, // Fixed height to prevent unbounded error
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(50),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Movimientos Recientes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AsyncValueHandler(
                  value: detailAsync,
                  data: (detail) {
                    return ManualMovementsCard(
                      detail: detail,
                      currencyFormat: currencyFormat,
                    );
                  },
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorBuilder: (e, st) =>
                      Center(child: Text('Error al cargar movimientos: $e')),
                ),
              ),
            ],
          ),
        );
      },
      loadingWidget: const SizedBox.shrink(),
      errorBuilder: (e, st) => const SizedBox.shrink(),
    );
  }
}
