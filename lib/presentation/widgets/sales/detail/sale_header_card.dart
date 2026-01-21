import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale.dart';

class SaleHeaderCard extends StatelessWidget {
  final Sale sale;

  const SaleHeaderCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final dateFormat = DateFormat('dd MMM yyyy · HH:mm', 'es');
    final isCancelled = sale.status == SaleStatus.cancelled;
    final isReturned = sale.status == SaleStatus.returned;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (isCancelled) {
      statusColor = cs.error;
      statusLabel = 'CANCELADA';
      statusIcon = Icons.cancel_outlined;
    } else if (isReturned) {
      statusColor = AppTheme.alertWarning;
      statusLabel = 'DEVUELTA';
      statusIcon = Icons.keyboard_return_outlined;
    } else {
      statusColor = AppTheme.transactionSuccess;
      statusLabel = 'COMPLETADA';
      statusIcon = Icons.check_circle_outline;
    }

    // Modern Stat Card Design
    return Container(
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.15)),
      ),
      child: Stack(
        children: [
          // Background Icon Watermark
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.05,
              child: Icon(statusIcon, size: 150, color: statusColor),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Folio Badge and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: cs.shadow.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            sale.saleNumber,
                            style: tt.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
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
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Main Content Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Customer & Date
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatItem(
                            label: 'Cliente',
                            value: sale.customerName ?? 'Público General',
                            icon: Icons.person_outline,
                            color: cs.onSurface,
                          ),
                          const SizedBox(height: 16),
                          _StatItem(
                            label: 'Fecha y Hora',
                            value: dateFormat.format(sale.saleDate),
                            icon: Icons.calendar_today_outlined,
                            color: cs.onSurfaceVariant,
                            isSubtle: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right Column: Warehouse & Reason if cancelled
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatItem(
                            label: 'Almacén',
                            value: 'Almacén #${sale.warehouseId}',
                            icon: Icons.warehouse_outlined,
                            color: cs.onSurfaceVariant,
                            isSubtle: true,
                          ),
                          if (isCancelled &&
                              sale.cancellationReason != null) ...[
                            const SizedBox(height: 16),
                            _StatItem(
                              label: 'Motivo Cancelación',
                              value: sale.cancellationReason!,
                              icon: Icons.info_outline,
                              color: cs.error,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isSubtle;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isSubtle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: isSubtle
                    ? tt.bodyMedium?.copyWith(color: color)
                    : tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
