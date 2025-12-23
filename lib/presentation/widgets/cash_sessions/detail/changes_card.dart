import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:posventa/presentation/providers/cash_session_providers.dart';

class ChangesCard extends StatelessWidget {
  final CashSessionDetail detail;
  final NumberFormat currencyFormat;

  const ChangesCard({
    super.key,
    required this.detail,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    // Filter only "Change" movements
    // Assuming we use 'withdrawal' type and reason 'Cambio' based on previous implementation
    final changes = detail.movements
        .where((m) => m.reason == 'Cambio')
        .toList();

    if (changes.isEmpty) return const SizedBox.shrink();

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
                  Icons.change_circle_outlined,
                  color: Colors.orange, // Distinct color for change
                ),
                const SizedBox(width: 8),
                Text(
                  'Cambios Entregados',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: changes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final movement = changes[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withAlpha(25),
                    child: const Icon(Icons.remove, color: Colors.orange),
                  ),
                  title: Text(
                    movement.description ?? movement.reason,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(movement.movementDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Text(
                    '-${currencyFormat.format(movement.amountCents.abs() / 100)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.orange,
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
