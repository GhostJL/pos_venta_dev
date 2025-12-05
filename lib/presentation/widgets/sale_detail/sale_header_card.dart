import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale.dart';

class SaleHeaderCard extends StatelessWidget {
  final Sale sale;

  const SaleHeaderCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');
    final isCancelled = sale.status == SaleStatus.cancelled;
    final isReturned = sale.status == SaleStatus.returned;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: isCancelled
                      ? AppTheme.actionCancel
                      : isReturned
                      ? AppTheme.alertWarning
                      : AppTheme.transactionSuccess,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.saleNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(sale.saleDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? AppTheme.actionCancel
                      : isReturned
                      ? AppTheme.alertWarning
                      : AppTheme.transactionSuccess,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCancelled
                        ? AppTheme.actionCancel
                        : isReturned
                        ? AppTheme.alertWarning
                        : AppTheme.transactionSuccess,
                  ),
                ),
                child: Text(
                  isCancelled
                      ? 'Cancelada'
                      : isReturned
                      ? 'Devuelta'
                      : 'Completada',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCancelled
                        ? AppTheme.onActionCancel
                        : isReturned
                        ? AppTheme.onAlertWarning
                        : AppTheme.onAlertSuccess,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          _buildInfoRow(
            context,
            Icons.person_outline,
            'Cliente',
            sale.customerName ?? 'Público General',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.warehouse_outlined,
            'Almacén',
            'Almacén #${sale.warehouseId}',
          ),
          if (isCancelled) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.cancel_outlined,
              'Motivo de cancelación',
              sale.cancellationReason ?? 'No especificado',
              isError: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isError = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isError
                  ? Theme.of(context).colorScheme.error
                  : Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
