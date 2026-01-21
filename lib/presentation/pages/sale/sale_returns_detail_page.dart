import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:posventa/domain/usecases/sale/print_sale_ticket_use_case.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
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
            onPressed: () async {
              if (!context.mounted) return;
              _printTicket(context, ref, sale);
            },
            tooltip: 'Imprimir Ticket de Venta',
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
      debugPrint('Error in reprint: $e');
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
