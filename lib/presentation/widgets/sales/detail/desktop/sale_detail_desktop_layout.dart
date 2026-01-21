import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/widgets/sales/detail/common/sale_timeline.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_action_buttons.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_header_card.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_payments_list.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_products_list.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_returns_section.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_totals_card.dart';

class SaleDetailDesktopLayout extends StatelessWidget {
  final Sale sale;

  const SaleDetailDesktopLayout({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Products List (Independent Scroll)
        Expanded(
          flex: 5, // Slightly wider for products
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: cs.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalle de Productos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${sale.items.length} artículos registrados',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: Container(
                  color: cs.surfaceContainerLow.withValues(alpha: 0.3),
                  child: SaleProductsList(
                    sale: sale,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right Column: Dashboard Panel (Scrollable)
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                left: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(-4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Header Card (Status & KPIs)
                        SaleHeaderCard(sale: sale),

                        const SizedBox(height: 24),

                        // 2. Timeline Section
                        _SectionCard(
                          title: 'Actividad',
                          child: SaleTimeline(sale: sale),
                        ),

                        const SizedBox(height: 24),

                        // 3. Returns Section (if any)
                        SaleReturnsSection(sale: sale),

                        // Spacing if returns exist will be handled by the widget or here
                        if (sale.status == SaleStatus.returned)
                          const SizedBox(height: 24),

                        // 4. Financials
                        _SectionCard(
                          title: 'Resumen Financiero',
                          child: Column(
                            children: [
                              SaleTotalsCard(sale: sale),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              SalePaymentsList(sale: sale),
                            ],
                          ),
                        ),

                        // Bottom padding for scrolling space
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // Sticky Action Bar
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(
                      top: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SaleActionButtons(sale: sale),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional Header if needed, but SaleTimeline has its own title usually.
          // If we want to standardize headers:
          /*
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          */
          // For now, just wrapper
          child,
        ],
      ),
    );
  }
}
