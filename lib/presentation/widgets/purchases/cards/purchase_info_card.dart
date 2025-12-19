import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/purchase.dart';

class PurchaseInfoCard extends StatelessWidget {
  final Purchase purchase;

  const PurchaseInfoCard({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final dateFormat = DateFormat('dd MMM yyyy · HH:mm', 'es');
    final status = purchase.status;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case PurchaseStatus.pending:
        statusColor = AppTheme.transactionPending;
        statusLabel = 'PENDIENTE';
        break;
      case PurchaseStatus.partial:
        statusColor = cs.primary;
        statusLabel = 'PARCIAL';
        break;
      case PurchaseStatus.cancelled:
        statusColor = cs.error;
        statusLabel = 'CANCELADA';
        break;
      case PurchaseStatus.completed:
        statusColor = AppTheme.transactionSuccess;
        statusLabel = 'RECIBIDA';
        break;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.purchaseNumber,
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(purchase.purchaseDate),
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(color: statusColor, label: statusLabel),
              ],
            ),
            const SizedBox(height: 24),
            _InfoItem(
              icon: Icons.business_outlined,
              label: 'Proveedor',
              value: purchase.supplierName ?? 'N/A',
            ),
            const SizedBox(height: 16),
            if (purchase.supplierInvoiceNumber != null) ...[
              _InfoItem(
                icon: Icons.receipt_outlined,
                label: 'Factura Proveedor',
                value: purchase.supplierInvoiceNumber!,
              ),
              const SizedBox(height: 16),
            ],
            if (purchase.receivedDate != null) ...[
              _InfoItem(
                icon: Icons.warehouse_outlined,
                label: 'Última Recepción',
                value: dateFormat.format(purchase.receivedDate!),
              ),
              const SizedBox(height: 16),
            ],
            _InfoItem(
              icon: Icons.location_on_outlined,
              label: 'Almacén',
              value: 'Almacén #${purchase.warehouseId}',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _StatusBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              value,
              style: tt.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
