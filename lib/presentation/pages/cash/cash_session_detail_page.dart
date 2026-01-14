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

class CashSessionDetailPage extends ConsumerStatefulWidget {
  final CashSession session;

  const CashSessionDetailPage({super.key, required this.session});

  @override
  ConsumerState<CashSessionDetailPage> createState() =>
      _CashSessionDetailPageState();
}

class _CashSessionDetailPageState extends ConsumerState<CashSessionDetailPage> {
  // 0 = Manual Movements, 1 = Changes
  int _movementsViewIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(cashSessionDetailProvider(widget.session));
    final warehousesAsync = ref.watch(warehouseProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sesión #${widget.session.id}'),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.session.status == 'open'
                    ? AppTheme.transactionSuccess.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.session.status == 'open'
                      ? AppTheme.transactionSuccess.withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: widget.session.status == 'open'
                        ? AppTheme.transactionSuccess
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.session.status == 'open' ? 'ABIERTA' : 'CERRADA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.session.status == 'open'
                          ? AppTheme.transactionSuccess
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Resumen'),
              Tab(text: 'Movimientos'),
            ],
          ),
        ),
        body: detailAsync.when(
          data: (detail) {
            return TabBarView(
              children: [
                // Tab 1: Resumen
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 900) {
                      // Mobile Summary
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SessionInfoCard(
                              session: widget.session,
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
                          ],
                        ),
                      );
                    } else {
                      // Desktop Summary
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SessionInfoCard(
                                    session: widget.session,
                                    warehousesAsync: warehousesAsync,
                                    dateFormat: dateFormat,
                                  ),
                                  const SizedBox(height: 24),
                                  FinancialSummaryCard(
                                    detail: detail,
                                    currencyFormat: currencyFormat,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  SalesSummaryCard(
                                    detail: detail,
                                    currencyFormat: currencyFormat,
                                  ),
                                  const SizedBox(height: 24),
                                  PaymentMethodsCard(
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
                ),

                // Tab 2: Movimientos with Segmented Control
                Column(
                  children: [
                    const SizedBox(height: 16),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          label: Text('Manuales'),
                          icon: Icon(Icons.swap_vert_rounded),
                        ),
                        ButtonSegment(
                          value: 1,
                          label: Text('Cambios'),
                          icon: Icon(Icons.change_circle_outlined),
                        ),
                      ],
                      selected: {_movementsViewIndex},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          _movementsViewIndex = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _movementsViewIndex == 0
                          ? ManualMovementsCard(
                              detail: detail,
                              currencyFormat: currencyFormat,
                            )
                          : ChangesCard(
                              detail: detail,
                              currencyFormat: currencyFormat,
                            ),
                    ),
                  ],
                ),
              ],
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
      ),
    );
  }
}
