import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:posventa/presentation/providers/cash_session_providers.dart';

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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumen Financiero',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildFinancialRow(
              context,
              'Fondo Inicial',
              session.openingBalanceCents,
              currencyFormat,
            ),
            const SizedBox(height: 8),
            _buildFinancialRow(
              context,
              'Ventas en Efectivo',
              detail.totalCashSales,
              currencyFormat,
              color: Colors.green,
              prefix: '+',
            ),
            const SizedBox(height: 8),
            _buildFinancialRow(
              context,
              'Movimientos Manuales',
              detail.totalManualMovements,
              currencyFormat,
              color: detail.totalManualMovements >= 0
                  ? Colors.green
                  : Colors.red,
              prefix: detail.totalManualMovements >= 0 ? '+' : '',
            ),
            const Divider(height: 24),
            _buildFinancialRow(
              context,
              'Balance Esperado',
              detail.expectedBalance,
              currencyFormat,
              isBold: true,
            ),
            if (session.closingBalanceCents != null) ...[
              const SizedBox(height: 8),
              _buildFinancialRow(
                context,
                'Balance Contado',
                session.closingBalanceCents!,
                currencyFormat,
                isBold: true,
              ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: difference == 0
                      ? Colors.blue.withAlpha(25)
                      : (isNegative
                            ? Colors.red.withAlpha(25)
                            : Colors.green.withAlpha(25)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
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
                          color: difference == 0
                              ? Colors.blue
                              : (isNegative ? Colors.red : Colors.green),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Diferencia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: difference == 0
                                ? Colors.blue
                                : (isNegative ? Colors.red : Colors.green),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currencyFormat.format(difference / 100),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: difference == 0
                            ? Colors.blue
                            : (isNegative ? Colors.red : Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '$prefix${format.format(amountCents / 100)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
