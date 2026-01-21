import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:posventa/presentation/widgets/sales/common/sale_payment_method_chip.dart';
import 'package:posventa/presentation/widgets/sales/common/sale_status_badge.dart';
import 'package:posventa/domain/usecases/sale/print_sale_ticket_use_case.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';

/// Desktop-optimized sale card styled as an interactive data row
class SaleCardDesktop extends ConsumerStatefulWidget {
  final Sale sale;

  const SaleCardDesktop({super.key, required this.sale});

  @override
  ConsumerState<SaleCardDesktop> createState() => _SaleCardDesktopState();
}

class _SaleCardDesktopState extends ConsumerState<SaleCardDesktop> {
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

    // Calculate totals breakdown locally for display
    final subtotalRaw = widget.sale.subtotalCents / 100;
    final taxRaw = widget.sale.taxCents / 100;
    final totalRaw = widget.sale.totalCents / 100;

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
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _isHovered ? cs.surfaceContainerHigh : cs.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? cs.primary.withValues(alpha: 0.3)
                  : cs.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 1. Status Badge (Fixed width)
                SizedBox(
                  width: 140,
                  child: SaleStatusBadge(
                    color: statusColor,
                    label: statusLabel,
                    icon: statusIcon,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 24),

                // 2. Sale Info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.sale.saleNumber,
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (returns.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'Esta venta tiene devoluciones',
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppTheme.transactionRefund,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        saleDateText,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Customer
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: cs.primaryContainer,
                        child: Text(
                          (widget.sale.customerName ?? 'P')[0],
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.sale.customerName ?? 'Público General',
                          style: tt.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Payment Method
                SizedBox(
                  width: 120,
                  child: Row(
                    children: paymentMethods.take(2).map((method) {
                      final color = SalePaymentMethodChip.getColorForMethod(
                        method,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Tooltip(
                          message: method,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              SalePaymentMethodChip.getIconForMethod(method),
                              size: 14,
                              color: color,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // 5. Products Preview (Hover Trigger)
                SizedBox(
                  width: 100,
                  child: Tooltip(
                    richMessage: WidgetSpan(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Productos (${widget.sale.items.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 8),
                            ...widget.sale.items
                                .take(5)
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${item.quantity.toInt()}x ',
                                          style: TextStyle(
                                            color: cs.secondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            item.productName ?? 'Unknown',
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            if (widget.sale.items.length > 5)
                              Text(
                                '+ ${widget.sale.items.length - 5} más...',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: cs.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.sale.items.length} items',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Monetary Totals
                SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$ ${(totalRaw).toStringAsFixed(2)}',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCancelled ? cs.error : cs.onSurface,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      if (returns.isNotEmpty)
                        Text(
                          'Dev: -\$ ${(totalReturnedCents / 100).toStringAsFixed(2)}',
                          style: tt.bodySmall?.copyWith(
                            color: AppTheme.transactionRefund,
                            fontSize: 10,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                    ],
                  ),
                ),

                // 7. Actions (Visible on Hover)
                SizedBox(
                  width: 100,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isCancelled)
                          IconButton(
                            icon: const Icon(Icons.print_outlined),
                            iconSize: 20,
                            tooltip: 'Imprimir Ticket',
                            onPressed: () =>
                                _printTicket(context, ref, widget.sale),
                          ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          iconSize: 20,
                          tooltip: 'Ver Detalles',
                          onPressed: () =>
                              context.push('/sale-detail/${widget.sale.id}'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _printTicket(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    try {
      final useCase = await ref.read(printSaleTicketUseCaseProvider.future);
      final result = await useCase.execute(
        sale: sale,
        cashier: ref.read(authProvider).user,
      );

      if (!context.mounted) return;

      switch (result) {
        case TicketPrinted():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ticket enviado a imprimir'),
              backgroundColor: Colors.green,
            ),
          );
        case TicketPdfSaved(:final path):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ticket guardado como PDF en: $path'),
              backgroundColor: Colors.green,
            ),
          );
        case TicketPrintFailure(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al imprimir: $message'),
              backgroundColor: Colors.red,
            ),
          );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
