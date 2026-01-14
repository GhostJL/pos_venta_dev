import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/core/theme/theme.dart';

class CashSessionCard extends StatelessWidget {
  final CashSession session;

  const CashSessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final isOpen = session.status == 'open';
    final currencyFormat = NumberFormat.currency(symbol: '\$');
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
      child: InkWell(
        onTap: () => context.push('/cash-sessions/detail', extra: session),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status Badge + ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? AppTheme.transactionSuccess.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOpen
                            ? AppTheme.transactionSuccess.withValues(alpha: 0.2)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: isOpen
                              ? AppTheme.transactionSuccess
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isOpen ? 'ABIERTA' : 'CERRADA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOpen
                                ? AppTheme.transactionSuccess
                                : colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '#${session.id}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(
                      (session.userName ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.userName ?? 'Usuario ID: ${session.userId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Balances
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceRow(
                      context,
                      'Inicio',
                      session.openingBalanceCents / 100,
                      currencyFormat,
                    ),
                    if (!isOpen) ...[
                      const SizedBox(height: 4),
                      Divider(
                        height: 12,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      _buildBalanceRow(
                        context,
                        'Cierre',
                        (session.closingBalanceCents ?? 0) / 100,
                        currencyFormat,
                        isBold: true,
                      ),
                      if (session.differenceCents != null &&
                          session.differenceCents != 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Diferencia',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                currencyFormat.format(
                                  session.differenceCents! / 100,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: session.differenceCents! < 0
                                      ? AppTheme.transactionFailed
                                      : AppTheme.transactionSuccess,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Timestamps
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      isOpen
                          ? 'Abierto: ${_formatDate(session.openedAt)}'
                          : 'Cerrado: ${_formatDate(session.closedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceRow(
    BuildContext context,
    String label,
    double amount,
    NumberFormat format, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          format.format(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM HH:mm').format(date);
  }
}
