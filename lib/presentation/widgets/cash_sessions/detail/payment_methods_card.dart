import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:posventa/presentation/providers/cash_session_providers.dart';

class PaymentMethodsCard extends StatelessWidget {
  final CashSessionDetail detail;
  final NumberFormat currencyFormat;

  const PaymentMethodsCard({
    super.key,
    required this.detail,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    // Group payments by method
    final paymentsByMethod = <String, int>{};
    for (final payment in detail.payments) {
      paymentsByMethod[payment.paymentMethod] =
          (paymentsByMethod[payment.paymentMethod] ?? 0) + payment.amountCents;
    }

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
                  Icons.payment_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Métodos de Pago',
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
              children: [
                if (paymentsByMethod.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'No hay pagos registrados',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  ...paymentsByMethod.entries.map((entry) {
                    final normalizedKey = entry.key.toLowerCase();
                    final isCash = normalizedKey == 'efectivo';
                    final isCard = normalizedKey.contains('tarjeta');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCash
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : (isCard
                                        ? Colors.blue.withValues(alpha: 0.1)
                                        : colorScheme.primaryContainer),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getPaymentIcon(entry.key),
                              size: 20,
                              color: isCash
                                  ? Colors.green
                                  : (isCard
                                        ? Colors.blue
                                        : colorScheme.primary),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            currencyFormat.format(entry.value / 100),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'efectivo':
        return Icons.money;
      case 'tarjeta':
      case 'tarjeta de crédito':
      case 'tarjeta de débito':
        return Icons.credit_card;
      case 'transferencia':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}
