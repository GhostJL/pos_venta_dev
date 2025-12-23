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
                  Icons.swap_vert_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Movimientos Manuales',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (filteredMovements.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('No hay movimientos manuales en esta sesión.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredMovements.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
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
                    backgroundColor = AppTheme.transactionSuccess.withAlpha(25);
                  } else if (isReturn) {
                    iconColor = Colors.orange;
                    iconData = Icons.assignment_return;
                    backgroundColor = Colors.orange.withAlpha(25);
                  } else {
                    iconColor = AppTheme.transactionFailed;
                    iconData = Icons.remove;
                    backgroundColor = Theme.of(
                      context,
                    ).colorScheme.error.withAlpha(25);
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: backgroundColor,
                      child: Icon(iconData, color: iconColor),
                    ),
                    title: Text(
                      movement.reason,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (movement.description != null &&
                            movement.description!.isNotEmpty)
                          Text(movement.description!),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(movement.movementDate),
                          style: Theme.of(context).textTheme.bodySmall,
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
              ),
          ],
        ),
      ),
    );
  }
}
