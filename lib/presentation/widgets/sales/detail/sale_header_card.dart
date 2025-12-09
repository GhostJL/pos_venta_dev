import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/widgets/common/base/base_card.dart';
import 'package:posventa/presentation/widgets/common/base/info_row.dart';

class SaleHeaderCard extends StatelessWidget {
  final Sale sale;

  const SaleHeaderCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');
    final isCancelled = sale.status == SaleStatus.cancelled;
    final isReturned = sale.status == SaleStatus.returned;

    return BaseCard(
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          InfoRow(
            icon: Icons.person_outline,
            label: 'Cliente',
            value: sale.customerName ?? 'Público General',
            labelWidth: 120,
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.warehouse_outlined,
            label: 'Almacén',
            value: 'Almacén #${sale.warehouseId}',
            labelWidth: 120,
          ),
          if (isCancelled) ...[
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.cancel_outlined,
              label: 'Motivo de cancelación',
              value: sale.cancellationReason ?? 'No especificado',
              labelWidth: 120,
              isError: true,
            ),
          ],
        ],
      ),
    );
  }
}
