import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_action_buttons.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_header_card.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_payments_list.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_products_list.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_returns_section.dart';
import 'package:posventa/presentation/widgets/sales/detail/sale_totals_card.dart';

class SaleDetailPage extends ConsumerWidget {
  final int saleId;

  const SaleDetailPage({super.key, required this.saleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleDetailStreamProvider(saleId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Detalle de Venta',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de impresión próximamente'),
                ),
              );
            },
            tooltip: 'Imprimir Ticket',
          ),
        ],
      ),
      body: saleAsync.when(
        data: (sale) {
          if (sale == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Venta no encontrada',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildSaleDetail(context, ref, sale);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaleDetail(BuildContext context, WidgetRef ref, Sale sale) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isBroad = constraints.maxWidth >= 900;

        if (isBroad) {
          // Desktop Layout (2 Columns)
          // Left: Independent List for Products
          // Right: Detailed Info (Header, Totals, Actions, Payments)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Products List (Independent Scroll)
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Text(
                        'Productos (${sale.items.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: SaleProductsList(
                        sale: sale,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      ),
                    ),
                  ],
                ),
              ),
              // Right Column: Summary & Actions (Scrollable)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SaleHeaderCard(sale: sale),
                        SaleReturnsSection(sale: sale),
                        const SizedBox(height: 24),
                        SaleTotalsCard(sale: sale),
                        const SizedBox(height: 24),
                        SaleActionButtons(sale: sale),
                        const SizedBox(height: 32),
                        SalePaymentsList(sale: sale),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile Layout (Tabs)
          // Tab 1: Resumen (Header, Returns, Totals, Actions)
          // Tab 2: Productos (Full List)
          // Tab 3: Pagos (Full List)
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
                          children: [
                            SaleHeaderCard(sale: sale),
                            SaleReturnsSection(sale: sale),
                            const SizedBox(height: 24),
                            SaleTotalsCard(sale: sale),
                            const SizedBox(height: 24),
                            SaleActionButtons(sale: sale),
                          ],
                        ),
                      ),
                      // Tab 2: Productos (List)
                      SaleProductsList(
                        sale: sale,
                        padding: const EdgeInsets.all(16),
                      ),
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
      },
    );
  }
}
