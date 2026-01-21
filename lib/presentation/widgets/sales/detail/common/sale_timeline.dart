import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';

class SaleTimeline extends ConsumerWidget {
  final Sale sale;

  const SaleTimeline({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsAsync = ref.watch(saleReturnsForSaleProvider(sale.id!));
    final returns = returnsAsync;

    // Build event list
    final events = <_TimelineEvent>[];

    // 1. Creation
    events.add(
      _TimelineEvent(
        timestamp: sale.saleDate,
        type: _TimelineEventType.created,
        title: 'Venta Registrada',
        description:
            'Cajero #${sale.cashierId}', // Todo: Use user name if available
      ),
    );

    // 2. Payments
    for (final payment in sale.payments) {
      events.add(
        _TimelineEvent(
          timestamp: payment.paymentDate,
          type: _TimelineEventType.payment,
          title: 'Pago Recibido',
          description:
              '${payment.paymentMethod} • \$${(payment.amountCents / 100).toStringAsFixed(2)}',
        ),
      );
    }

    // 3. Returns
    for (final ret in returns) {
      events.add(
        _TimelineEvent(
          timestamp: ret.returnDate,
          type: _TimelineEventType.returned,
          title: 'Devolución Procesada',
          description:
              'Reembolso: \$${(ret.totalCents / 100).toStringAsFixed(2)} (${ret.refundMethod.displayName})',
        ),
      );
    }

    // 4. Cancellation
    if (sale.status == SaleStatus.cancelled && sale.cancelledAt != null) {
      events.add(
        _TimelineEvent(
          timestamp: sale.cancelledAt!,
          type: _TimelineEventType.cancelled,
          title: 'Venta Cancelada',
          description: sale.cancellationReason ?? 'Sin razón especificada',
        ),
      );
    }

    // Sort by timestamp descending (newest first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Línea de Tiempo',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final isLast = index == events.length - 1;
            return _TimelineItem(
              event: event,
              isLast: isLast,
              isFirst: index == 0,
            );
          },
        ),
      ],
    );
  }
}

enum _TimelineEventType { created, payment, returned, cancelled }

class _TimelineEvent {
  final DateTime timestamp;
  final _TimelineEventType type;
  final String title;
  final String description;

  _TimelineEvent({
    required this.timestamp,
    required this.type,
    required this.title,
    required this.description,
  });
}

class _TimelineItem extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast;
  final bool isFirst;

  const _TimelineItem({
    required this.event,
    required this.isLast,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    IconData icon;
    Color color;
    Color bgColor;

    switch (event.type) {
      case _TimelineEventType.created:
        icon = Icons.flag_outlined;
        color = cs.primary;
        bgColor = cs.primaryContainer;
        break;
      case _TimelineEventType.payment:
        icon = Icons.attach_money;
        color = Colors.green; // Hardcoded distinct green
        bgColor = Colors.green.withValues(alpha: 0.1);
        break;
      case _TimelineEventType.returned:
        icon = Icons.keyboard_return;
        color = Colors.orange.shade700;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      case _TimelineEventType.cancelled:
        icon = Icons.block;
        color = cs.error;
        bgColor = cs.errorContainer;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line and Dot
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // Top Line (if not first)
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 16,
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  )
                else
                  const SizedBox(height: 16),

                // Dot/Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),

                // Bottom Line (if not last)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                  )
                else
                  // Ensure nice spacing even if last
                  const Spacer(),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 0, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(event.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM y').format(event.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: cs.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
