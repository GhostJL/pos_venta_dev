import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/widgets/sale_detail/sale_action_buttons.dart';
import 'package:posventa/presentation/widgets/sale_detail/sale_header_card.dart';
import 'package:posventa/presentation/widgets/sale_detail/sale_payments_list.dart';
import 'package:posventa/presentation/widgets/sale_detail/sale_products_list.dart';
import 'package:posventa/presentation/widgets/sale_detail/sale_returns_section.dart';
import 'package:posventa/presentation/widgets/sale_detail/sale_totals_card.dart';

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
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SaleHeaderCard(sale: sale),
          SaleReturnsSection(sale: sale),
          const SizedBox(height: 32),
          SaleProductsList(sale: sale),
          SalePaymentsList(sale: sale),
          const SizedBox(height: 32),
          SaleTotalsCard(sale: sale),
          SaleActionButtons(sale: sale),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
