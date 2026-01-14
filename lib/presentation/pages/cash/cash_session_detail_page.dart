import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/widgets/cash_sessions/detail/session_info_card.dart';
import 'package:posventa/presentation/widgets/cash_sessions/detail/financial_summary_card.dart';
import 'package:posventa/presentation/widgets/cash_sessions/detail/sales_summary_card.dart';
import 'package:posventa/presentation/widgets/cash_sessions/detail/manual_movements_card.dart';
import 'package:posventa/presentation/widgets/cash_sessions/detail/changes_card.dart';
import 'package:posventa/presentation/widgets/cash_sessions/detail/payment_methods_card.dart';
import 'package:posventa/core/theme/theme.dart';

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: session.status == 'open'
                  ? AppTheme.transactionSuccess.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: session.status == 'open'
                    ? AppTheme.transactionSuccess.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: session.status == 'open'
                      ? AppTheme.transactionSuccess
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  session.status == 'open' ? 'ABIERTA' : 'CERRADA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: session.status == 'open'
                        ? AppTheme.transactionSuccess
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: detailAsync.when(
        data: (detail) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                // Mobile Layout (Single Column)
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SessionInfoCard(
                        session: session,
                        warehousesAsync: warehousesAsync,
                        dateFormat: dateFormat,
                      ),
                      const SizedBox(height: 16),
                      FinancialSummaryCard(
                        detail: detail,
                        currencyFormat: currencyFormat,
                      ),
                      const SizedBox(height: 16),
                      SalesSummaryCard(
                        detail: detail,
                        currencyFormat: currencyFormat,
                      ),
                      const SizedBox(height: 16),
                      PaymentMethodsCard(
                        detail: detail,
                        currencyFormat: currencyFormat,
                      ),
                      const SizedBox(height: 16),
                      ManualMovementsCard(
                        detail: detail,
                        currencyFormat: currencyFormat,
                      ),
                      const SizedBox(height: 16),
                      ChangesCard(
                        detail: detail,
                        currencyFormat: currencyFormat,
                      ),
                    ],
                  ),
                );
              } else {
                // Desktop Layout (Two Columns)
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Key Info & Financials
                      Expanded(
                        child: Column(
                          children: [
                            SessionInfoCard(
                              session: session,
                              warehousesAsync: warehousesAsync,
                              dateFormat: dateFormat,
                            ),
                            const SizedBox(height: 24),
                            FinancialSummaryCard(
                              detail: detail,
                              currencyFormat: currencyFormat,
                            ),
                            const SizedBox(height: 24),
                            SalesSummaryCard(
                              detail: detail,
                              currencyFormat: currencyFormat,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column: Breakdown & Logs
                      Expanded(
                        child: Column(
                          children: [
                            PaymentMethodsCard(
                              detail: detail,
                              currencyFormat: currencyFormat,
                            ),
                            const SizedBox(height: 24),
                            ManualMovementsCard(
                              detail: detail,
                              currencyFormat: currencyFormat,
                            ),
                            const SizedBox(height: 24),
                            ChangesCard(
                              detail: detail,
                              currencyFormat: currencyFormat,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error: $err'),
            ],
          ),
        ),
      ),
    );
  }
}
