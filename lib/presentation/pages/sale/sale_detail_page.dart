import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/usecases/sale/print_sale_ticket_use_case.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:posventa/presentation/widgets/sales/detail/desktop/sale_detail_desktop_layout.dart';
import 'package:posventa/presentation/widgets/sales/detail/mobile/sale_detail_mobile_layout.dart';

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
            onPressed: () async {
              // Get Sale from current state if available
              final saleState = await ref.read(
                saleDetailStreamProvider(saleId).future,
              );
              if (saleState == null || !context.mounted) return;

              _printTicket(context, ref, saleState);
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
          return _buildSaleDetail(context, sale: sale);
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

  Widget _buildSaleDetail(BuildContext context, {required Sale sale}) {
    // Use MediaQuery instead of LayoutBuilder to avoid potential layout cycle/mutation errors
    // during navigation transitions.
    final width = MediaQuery.of(context).size.width;
    final isBroad = width >= 900;

    if (isBroad) {
      return SaleDetailDesktopLayout(sale: sale);
    } else {
      return SaleDetailMobileLayout(sale: sale);
    }
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
