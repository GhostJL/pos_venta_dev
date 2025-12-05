import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:posventa/presentation/providers/cash_session_providers.dart';

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
            if (detail.movements.isEmpty)
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
                itemCount: detail.movements.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final movement = detail.movements[index];
                  final isEntry = movement.movementType == 'entry';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isEntry
                          ? Colors.green.withAlpha(25)
                          : Colors.red.withAlpha(25),
                      child: Icon(
                        isEntry ? Icons.add : Icons.remove,
                        color: isEntry ? Colors.green : Colors.red,
                      ),
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
                        color: isEntry ? Colors.green : Colors.red,
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
