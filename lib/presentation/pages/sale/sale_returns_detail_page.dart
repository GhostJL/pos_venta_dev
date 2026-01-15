import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:posventa/presentation/widgets/sales/returns/detail/sale_return_card.dart';
import 'package:posventa/presentation/widgets/sales/returns/detail/sale_returns_header_card.dart';

class SaleReturnsDetailPage extends ConsumerWidget {
  final int saleId;
  final Sale sale;

  const SaleReturnsDetailPage({
    super.key,
    required this.saleId,
    required this.sale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returns = ref.watch(saleReturnsForSaleProvider(saleId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Devoluciones',
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
            tooltip: 'Imprimir',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de exportación próximamente'),
                ),
              );
            },
            tooltip: 'Exportar',
          ),
        ],
      ),

      body: _buildBody(context, returns),
    );
  }

  Widget _buildBody(BuildContext context, List<SaleReturn> returns) {
    if (returns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay devoluciones',
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

    final int totalReturnedCents = returns.fold<int>(
      0,
      (sum, returnItem) => sum + returnItem.totalCents,
    );
    final int netTotalCents = (sale.totalCents - totalReturnedCents).toInt();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SaleReturnsHeaderCard(
                sale: sale,
                returns: returns,
                totalReturnedCents: totalReturnedCents,
                netTotalCents: netTotalCents,
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Text(
                  'Historial',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...returns.map(
                (returnItem) => SaleReturnCard(returnItem: returnItem),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
