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

    return AsyncValueHandler<CashSession?>(
      value: currentSessionAsync,
      data: (session) {
        if (session == null) {
          return const SizedBox.shrink(); // Hide if no session
        }

        final detailAsync = ref.watch(cashSessionDetailProvider(session));

        return AsyncValueHandler(
          value: detailAsync,
          data: (detail) {
            return ManualMovementsCard(
              detail: detail,
              currencyFormat: currencyFormat,
            );
          },
          loadingWidget: const Center(child: CircularProgressIndicator()),
          errorBuilder: (e, st) => Text('Error al cargar movimientos: $e'),
        );
      },
      loadingWidget: const SizedBox.shrink(),
      errorBuilder: (e, st) => const SizedBox.shrink(),
    );
  }
}
