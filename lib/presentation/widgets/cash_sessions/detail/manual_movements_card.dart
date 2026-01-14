import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/core/theme/theme.dart';

class ManualMovementsCard extends StatelessWidget {
  final CashSessionDetail detail;
  final NumberFormat currencyFormat;

  const ManualMovementsCard({
    super.key,
    required this.detail,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out "Change" movements
    final filteredMovements = detail.movements
        .where((m) => m.reason != 'Cambio')
        .toList();

    final colorScheme = Theme.of(context).colorScheme;

    if (filteredMovements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_vert_rounded,
              size: 48,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay movimientos manuales',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMovements.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      itemBuilder: (context, index) {
        final movement = filteredMovements[index];
        final isEntry = movement.movementType == 'entry';
        final isReturn = movement.movementType == 'return';

        Color iconColor;
        IconData iconData;
        Color backgroundColor;

        if (isEntry) {
          iconColor = AppTheme.transactionSuccess;
          iconData = Icons.add;
          backgroundColor = AppTheme.transactionSuccess.withValues(alpha: 0.1);
        } else if (isReturn) {
          iconColor = Colors.orange;
          iconData = Icons.assignment_return;
          backgroundColor = Colors.orange.withValues(alpha: 0.1);
        } else {
          iconColor = AppTheme.transactionFailed;
          iconData = Icons.remove;
          backgroundColor = Theme.of(
            context,
          ).colorScheme.error.withValues(alpha: 0.1);
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          title: Text(
            movement.reason,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (movement.description != null &&
                  movement.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(movement.description!),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(movement.movementDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          trailing: Text(
            '${isEntry ? '+' : '-'}${currencyFormat.format(movement.amountCents.abs() / 100)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isEntry
                  ? AppTheme.transactionSuccess
                  : AppTheme.transactionFailed,
            ),
          ),
        );
      },
    );
  }
}
