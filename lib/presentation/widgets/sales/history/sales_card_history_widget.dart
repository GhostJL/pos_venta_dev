import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';

class SaleCardHistoryWidget extends ConsumerWidget {
  final Sale sale;

  const SaleCardHistoryWidget({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final dateFormat = DateFormat('dd MMM yyyy · HH:mm', 'es');
    final saleDateText = dateFormat.format(sale.saleDate);

    final isCancelled = sale.status == SaleStatus.cancelled;
    final isReturned = sale.status == SaleStatus.returned;

    Color statusColor;
    String statusLabel;
    if (isCancelled) {
      statusColor = cs.error;
      statusLabel = 'CANCELADA';
    } else if (isReturned) {
      statusColor = AppTheme.alertWarning;
      statusLabel = 'DEVUELTA';
    } else {
      statusColor = AppTheme.transactionSuccess;
      statusLabel = 'COMPLETADA';
    }

    final returns = ref.watch(saleReturnsForSaleProvider(sale.id!));
    final totalReturnedCents = returns.fold(0, (sum, r) => sum + r.totalCents);
    final finalTotalCents = sale.totalCents - totalReturnedCents;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => context.push('/sale-detail/${sale.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          sale.saleNumber,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          saleDateText,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(color: statusColor, label: statusLabel),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sale.customerName ?? 'Público General',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${sale.items.length} ${sale.items.length == 1 ? 'producto' : 'productos'}',
                    style: tt.bodySmall,
                  ),
                  if (returns.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.keyboard_return_outlined,
                      size: 16,
                      color: AppTheme.alertWarning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Devolución activa',
                      style: tt.bodySmall?.copyWith(
                        color: AppTheme.alertWarning,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              if (returns.isEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    Text(
                      '\$ ${(sale.totalCents / 100).toStringAsFixed(2)}',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isCancelled ? cs.error : cs.primary,
                        letterSpacing: -0.5,
                        decoration: isCancelled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                )
              else ...[
                _TotalRow(
                  label: 'Total Original',
                  amount: sale.totalCents / 100,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 4),
                _TotalRow(
                  label: 'Devolución',
                  amount: -(totalReturnedCents / 100),
                  style: tt.bodySmall?.copyWith(
                    color: AppTheme.transactionRefund,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Final',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$ ${(finalTotalCents / 100).toStringAsFixed(2)}',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final TextStyle? style;

  const _TotalRow({required this.label, required this.amount, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '${amount < 0 ? '-' : ''}\$ ${amount.abs().toStringAsFixed(2)}',
          style: style,
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
