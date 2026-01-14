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
    final changes = detail.movements
        .where((m) => m.reason == 'Cambio')
        .toList();

    if (changes.isEmpty) return const SizedBox.shrink();

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
                const Icon(
                  Icons.change_circle_outlined,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Cambios Entregados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: changes.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final movement = changes[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                title: Text(
                  movement.description ?? movement.reason,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(movement.movementDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
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
    );
  }
}
