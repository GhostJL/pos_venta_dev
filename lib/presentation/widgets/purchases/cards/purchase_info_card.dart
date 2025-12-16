import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/purchase.dart';

class PurchaseInfoCard extends StatelessWidget {
  final Purchase purchase;

  const PurchaseInfoCard({super.key, required this.purchase});

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isPending = purchase.status == PurchaseStatus.pending;
    final isCancelled = purchase.status == PurchaseStatus.cancelled;
    final isPartial = purchase.status == PurchaseStatus.partial;

    Color statusColor;
    String statusText;
    if (isPending) {
      statusColor = AppTheme.transactionPending;
      statusText = 'Pendiente';
    } else if (isCancelled) {
      statusColor = Theme.of(context).colorScheme.error;
      statusText = 'Cancelada';
    } else if (isPartial) {
      statusColor = Theme.of(context).colorScheme.primary;
      statusText = 'Parcial';
    } else {
      statusColor = AppTheme.transactionSuccess;
      statusText = 'Recibida';
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header con número de compra y estado
            Row(
              children: [
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.purchaseNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormat.format(purchase.purchaseDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    statusText.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),

            _buildInfoRow(context, 'Proveedor', purchase.supplierName ?? 'N/A'),
            _buildInfoRow(
              context,
              'Fecha',
              dateFormat.format(purchase.purchaseDate),
            ),
            if (purchase.supplierInvoiceNumber != null)
              _buildInfoRow(
                context,
                'Factura Prov.',
                purchase.supplierInvoiceNumber!,
              ),
            if (purchase.receivedDate != null)
              _buildInfoRow(
                context,
                'Última Recepción',
                dateFormat.format(purchase.receivedDate!),
              ),
          ],
        ),
      ),
    );
  }
}
