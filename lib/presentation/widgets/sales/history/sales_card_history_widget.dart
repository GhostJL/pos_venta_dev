import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:posventa/presentation/widgets/sales/history/sale_header_widget.dart';
import 'package:posventa/presentation/widgets/sales/history/sale_info_row_widget.dart';
import 'package:posventa/presentation/widgets/sales/history/sale_returns_indicator_widget.dart';
import 'package:posventa/presentation/widgets/sales/history/sales_totals_row_widget.dart';

class SaleCardHistoryWidget extends ConsumerWidget {
  final Sale sale;

  const SaleCardHistoryWidget({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');
    final saleDateText = dateFormat.format(sale.saleDate);

    final isCancelled = sale.status == SaleStatus.cancelled;
    final isReturned = sale.status == SaleStatus.returned;

    final statusColor = isCancelled
        ? AppTheme.actionCancel
        : isReturned
        ? AppTheme.alertWarning
        : AppTheme.alertSuccess;

    final statusBorderColor = isCancelled
        ? AppTheme.actionCancel
        : isReturned
        ? AppTheme.alertWarning
        : AppTheme.transactionSuccess;

    final statusText = isCancelled
        ? 'Cancelada'
        : isReturned
        ? 'Devuelta'
        : 'Completada';

    final statusTextColor = isCancelled
        ? cs.onErrorContainer
        : isReturned
        ? AppTheme.onAlertWarning
        : cs.onPrimaryContainer;
    final returns = ref.watch(saleReturnsForSaleProvider(sale.id!));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: InkWell(
        onTap: () => context.push('/sale-detail/${sale.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SaleHeaderWidget(
                saleNumber: sale.saleNumber,
                saleDateText: saleDateText,
                statusColor: statusColor,
                statusBorderColor: statusBorderColor,
                statusText: statusText,
                statusTextColor: statusTextColor,
                isCancelled: isCancelled,
                isReturned: isReturned,
              ),

              const SizedBox(height: 16),

              SaleInfoRowWidget(
                itemCount: sale.items.length,
                textColor: cs.onSurfaceVariant,
              ),

              if (returns.isNotEmpty)
                SaleReturnsIndicatorWidget(returns: returns),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: cs.outline),
              ),

              SaleTotalsRowWidget(
                subtotal: sale.subtotalCents,
                tax: sale.taxCents,
                total: sale.totalCents,
                textColor: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
