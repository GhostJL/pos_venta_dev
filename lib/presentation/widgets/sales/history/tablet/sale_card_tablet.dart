import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:posventa/presentation/widgets/sales/common/sale_payment_method_chip.dart';
import 'package:posventa/presentation/widgets/sales/common/sale_status_badge.dart';

/// Tablet-optimized sale card with horizontal layout and item preview
class SaleCardTablet extends ConsumerStatefulWidget {
  final Sale sale;

  const SaleCardTablet({super.key, required this.sale});

  @override
  ConsumerState<SaleCardTablet> createState() => _SaleCardTabletState();
}

class _SaleCardTabletState extends ConsumerState<SaleCardTablet> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final dateFormat = DateFormat('dd MMM yyyy · HH:mm', 'es');
    final saleDateText = dateFormat.format(widget.sale.saleDate);

    final isCancelled = widget.sale.status == SaleStatus.cancelled;
    final isReturned = widget.sale.status == SaleStatus.returned;
    final isCredit = widget.sale.payments.any(
      (p) => p.paymentMethod == 'Crédito',
    );

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
    } else if (isCredit) {
      statusColor = cs.tertiary;
      statusLabel = 'CRÉDITO';
      statusIcon = Icons.receipt_long_outlined;
    } else {
      statusColor = AppTheme.transactionSuccess;
      statusLabel = 'COMPLETADA';
      statusIcon = Icons.check_circle_outline;
    }

    final returns = ref.watch(saleReturnsForSaleProvider(widget.sale.id!));
    final totalReturnedCents = returns.fold(0, (sum, r) => sum + r.totalCents);
    final finalTotalCents = widget.sale.totalCents - totalReturnedCents;

    // Get unique payment methods
    final paymentMethods = widget.sale.payments
        .map((p) => p.paymentMethod)
        .toSet()
        .toList();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push('/sale-detail/${widget.sale.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? cs.primary.withValues(alpha: 0.5)
                  : cs.outlineVariant.withValues(alpha: 0.5),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: _isHovered ? 0.08 : 0.02),
                blurRadius: _isHovered ? 8 : 4,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Decoration bar
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Sale #, Date, Customer
                        Row(
                          children: [
                            Text(
                              widget.sale.saleNumber,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              saleDateText,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            SaleStatusBadge(
                              color: statusColor,
                              label: statusLabel,
                              icon: statusIcon,
                              fontSize: 11,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.sale.customerName ?? 'Público General',
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        // Items Preview
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.sale.items.length} ${widget.sale.items.length == 1 ? 'producto' : 'productos'}',
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...widget.sale.items.take(3).map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${item.quantity.toStringAsFixed(item.unitOfMeasure == 'kg' ? 3 : 0)}x',
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item.productName ??
                                              'Producto #${item.productId}',
                                          style: tt.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (widget.sale.items.length > 3)
                                Text(
                                  '+ ${widget.sale.items.length - 3} más...',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right side: Totals and Payments
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border(
                      left: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Payments
                      if (paymentMethods.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: paymentMethods.map((method) {
                            // Find color for method
                            final methodColor =
                                SalePaymentMethodChip.getColorForMethod(method);
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Tooltip(
                                message: method,
                                child: Icon(
                                  SalePaymentMethodChip.getIconForMethod(
                                    method,
                                  ),
                                  size: 16,
                                  color: methodColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),
                      // Totals
                      if (returns.isEmpty) ...[
                        Text(
                          'Total',
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '\$ ${(widget.sale.totalCents / 100).toStringAsFixed(2)}',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isCancelled ? cs.error : cs.primary,
                            decoration: isCancelled
                                ? TextDecoration.lineThrough
                                : null,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Total Original',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '\$ ${(widget.sale.totalCents / 100).toStringAsFixed(2)}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Devolución',
                          style: tt.labelSmall?.copyWith(
                            color: AppTheme.transactionRefund,
                          ),
                        ),
                        Text(
                          '- \$ ${(totalReturnedCents / 100).toStringAsFixed(2)}',
                          style: tt.bodySmall?.copyWith(
                            color: AppTheme.transactionRefund,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$ ${(finalTotalCents / 100).toStringAsFixed(2)}',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.primary,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
