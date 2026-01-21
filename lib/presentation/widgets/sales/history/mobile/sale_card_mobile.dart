import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:posventa/presentation/widgets/sales/common/sale_status_badge.dart';

/// Mobile-optimized sale card with compact vertical layout
class SaleCardMobile extends ConsumerStatefulWidget {
  final Sale sale;

  const SaleCardMobile({super.key, required this.sale});

  @override
  ConsumerState<SaleCardMobile> createState() => _SaleCardMobileState();
}

class _SaleCardMobileState extends ConsumerState<SaleCardMobile> {
  bool _isPressed = false;

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

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.push('/sale-detail/${widget.sale.id}');
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _isPressed ? cs.surfaceContainerHighest : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sale.saleNumber,
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
                  SaleStatusBadge(
                    color: statusColor,
                    label: statusLabel,
                    icon: statusIcon,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              // Customer
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.sale.customerName ?? 'Público General',
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
              // Items count
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.sale.items.length} ${widget.sale.items.length == 1 ? 'producto' : 'productos'}',
                    style: tt.bodySmall,
                  ),
                ],
              ),
              if (returns.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.alertWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_return_outlined,
                        size: 14,
                        color: AppTheme.alertWarning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Devolución activa',
                        style: tt.bodySmall?.copyWith(
                          color: AppTheme.alertWarning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              // Total
              if (returns.isEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '\$ ${(widget.sale.totalCents / 100).toStringAsFixed(2)}',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isCancelled ? cs.error : cs.primary,
                        letterSpacing: -0.5,
                        decoration: isCancelled
                            ? TextDecoration.lineThrough
                            : null,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Original',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '\$ ${(widget.sale.totalCents / 100).toStringAsFixed(2)}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Devolución',
                          style: tt.bodySmall?.copyWith(
                            color: AppTheme.transactionRefund,
                          ),
                        ),
                        Text(
                          '-\$ ${(totalReturnedCents / 100).toStringAsFixed(2)}',
                          style: tt.bodySmall?.copyWith(
                            color: AppTheme.transactionRefund,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
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
                            fontFeatures: [const FontFeature.tabularFigures()],
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
