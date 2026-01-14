import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/core/theme/theme.dart';

class FinancialSummaryCard extends StatelessWidget {
  final CashSessionDetail detail;
  final NumberFormat currencyFormat;

  const FinancialSummaryCard({
    super.key,
    required this.detail,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final session = detail.session;
    final difference = session.differenceCents ?? 0;
    final isNegative = difference < 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Resumen Financiero',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFinancialRow(
                  context,
                  'Fondo Inicial',
                  session.openingBalanceCents,
                  currencyFormat,
                ),
                const SizedBox(height: 8),
                _buildFinancialRow(
                  context,
                  'Efectivo Recibido (Bruto)',
                  detail.totalCashTendered,
                  currencyFormat,
                  color: AppTheme.transactionSuccess,
                  prefix: '+',
                ),
                const SizedBox(height: 8),
                _buildFinancialRow(
                  context,
                  'Cambio Entregado',
                  -detail.totalChangeGiven,
                  currencyFormat,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                _buildFinancialRow(
                  context,
                  'Devoluciones en Efectivo',
                  -detail.totalCancellations,
                  currencyFormat,
                  color: Colors.orange,
                ),
                if (detail.totalRealManualMovements != 0) ...[
                  const SizedBox(height: 8),
                  _buildFinancialRow(
                    context,
                    'Salidas/Entradas Manuales',
                    detail.totalRealManualMovements,
                    currencyFormat,
                    color: detail.totalRealManualMovements >= 0
                        ? AppTheme.transactionSuccess
                        : AppTheme.transactionFailed,
                    prefix: detail.totalRealManualMovements >= 0 ? '+' : '',
                  ),
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),

                _buildFinancialRow(
                  context,
                  'EFECTIVO ESPERADO',
                  detail.expectedBalance,
                  currencyFormat,
                  isBold: true,
                ),

                if (session.closingBalanceCents != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: difference == 0
                          ? Colors.blue.withValues(alpha: 0.05)
                          : (isNegative
                                ? AppTheme.transactionFailed.withValues(
                                    alpha: 0.05,
                                  )
                                : AppTheme.transactionSuccess.withValues(
                                    alpha: 0.05,
                                  )),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: difference == 0
                            ? Colors.blue.withValues(alpha: 0.2)
                            : (isNegative
                                  ? AppTheme.transactionFailed.withValues(
                                      alpha: 0.2,
                                    )
                                  : AppTheme.transactionSuccess.withValues(
                                      alpha: 0.2,
                                    )),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildFinancialRow(
                          context,
                          'Balance Contado',
                          session.closingBalanceCents!,
                          currencyFormat,
                          isBold: true,
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  difference == 0
                                      ? Icons.check_circle_outline
                                      : (isNegative
                                            ? Icons.trending_down
                                            : Icons.trending_up),
                                  size: 20,
                                  color: difference == 0
                                      ? Colors.blue
                                      : (isNegative
                                            ? AppTheme.transactionFailed
                                            : AppTheme.transactionSuccess),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Diferencia',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: difference == 0
                                        ? Colors.blue
                                        : (isNegative
                                              ? AppTheme.transactionFailed
                                              : AppTheme.transactionSuccess),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              currencyFormat.format(difference / 100),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: difference == 0
                                    ? Colors.blue
                                    : (isNegative
                                          ? AppTheme.transactionFailed
                                          : AppTheme.transactionSuccess),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
    BuildContext context,
    String label,
    int amountCents,
    NumberFormat format, {
    bool isBold = false,
    Color? color,
    String prefix = '',
  }) {
    // Determine text style based on importance
    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final valueStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      fontFeatures: [const FontFeature.tabularFigures()],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: titleStyle)),
        Text('$prefix${format.format(amountCents / 100)}', style: valueStyle),
      ],
    );
  }
}
