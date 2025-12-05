import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/widgets/cash_session_detail/session_info_card.dart';
import 'package:posventa/presentation/widgets/cash_session_detail/financial_summary_card.dart';
import 'package:posventa/presentation/widgets/cash_session_detail/sales_summary_card.dart';
import 'package:posventa/presentation/widgets/cash_session_detail/manual_movements_card.dart';
import 'package:posventa/presentation/widgets/cash_session_detail/payment_methods_card.dart';

class CashSessionDetailPage extends ConsumerWidget {
  final CashSession session;

  const CashSessionDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(cashSessionDetailProvider(session));
    final warehousesAsync = ref.watch(warehouseProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Sesión #${session.id}'),
        actions: [
          if (session.status == 'open')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text('Abierta'),
                backgroundColor: Colors.green.withAlpha(50),
                labelStyle: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text('Cerrada'),
                backgroundColor: Colors.grey.withAlpha(50),
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: detailAsync.when(
        data: (detail) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session Info Card
                SessionInfoCard(
                  session: session,
                  warehousesAsync: warehousesAsync,
                  dateFormat: dateFormat,
                ),
                const SizedBox(height: 16),

                // Financial Summary Card
                FinancialSummaryCard(
                  detail: detail,
                  currencyFormat: currencyFormat,
                ),
                const SizedBox(height: 16),

                // Sales Summary Card
                SalesSummaryCard(
                  detail: detail,
                  currencyFormat: currencyFormat,
                ),
                const SizedBox(height: 16),

                // Manual Movements
                ManualMovementsCard(
                  detail: detail,
                  currencyFormat: currencyFormat,
                ),
                const SizedBox(height: 16),

                // Payment Methods Summary
                PaymentMethodsCard(
                  detail: detail,
                  currencyFormat: currencyFormat,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
            ],
          ),
        ),
      ),
    );
  }
}
