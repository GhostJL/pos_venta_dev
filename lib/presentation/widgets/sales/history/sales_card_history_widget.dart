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
    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');
    final isCancelled = sale.status == SaleStatus.cancelled;
    final isReturned = sale.status == SaleStatus.returned;
    final returnsAsync = ref.watch(saleReturnsForSaleProvider(sale.id!));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: InkWell(
        onTap: () {
          context.push('/sale-detail/${sale.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? AppTheme.actionCancel
                          : isReturned
                          ? AppTheme.alertWarning
                          : AppTheme.alertSuccess,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.saleNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormat.format(sale.saleDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
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
                      color: isCancelled
                          ? AppTheme.actionCancel
                          : isReturned
                          ? AppTheme.alertWarning
                          : AppTheme.alertSuccess,
                      borderRadius: BorderRadius.circular(6),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCancelled
                            ? Theme.of(context).colorScheme.onErrorContainer
                            : isReturned
                            ? AppTheme.onAlertWarning
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Info Row
              Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${sale.items.length} ${sale.items.length == 1 ? 'producto' : 'productos'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Return Indicator
              returnsAsync.when(
                data: (returns) {
                  if (returns.isEmpty) return const SizedBox.shrink();

                  final totalReturned = returns.fold<int>(
                    0,
                    (sum, r) => sum + r.totalCents,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.alertWarning,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.keyboard_return_outlined,
                            size: 14,
                            color: AppTheme.onAlertWarning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${returns.length} ${returns.length == 1 ? 'devolución' : 'devoluciones'} · -\$${(totalReturned / 100).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.onAlertWarning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),

              // Totals - Compact
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${(sale.subtotalCents / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Impuestos',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${(sale.taxCents / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${(sale.totalCents / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
