import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/widgets/sales/detail/common/sale_timeline.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_action_buttons.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_header_card.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_payments_list.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_products_list.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_returns_section.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_totals_card.dart';

class SaleDetailMobileLayout extends StatelessWidget {
  final Sale sale;

  const SaleDetailMobileLayout({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Resumen'),
              Tab(text: 'Productos'),
              Tab(text: 'Pagos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: Resumen
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SaleHeaderCard(sale: sale),
                      const SizedBox(height: 16),
                      // Timeline added to mobile summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: SaleTimeline(sale: sale),
                      ),
                      const SizedBox(height: 16),
                      SaleReturnsSection(sale: sale),
                      const SizedBox(height: 24),
                      SaleTotalsCard(sale: sale),
                      const SizedBox(height: 24),
                      SaleActionButtons(sale: sale),
                    ],
                  ),
                ),
                // Tab 2: Productos (List)
                SaleProductsList(sale: sale, padding: const EdgeInsets.all(16)),
                // Tab 3: Pagos
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SalePaymentsList(sale: sale),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
