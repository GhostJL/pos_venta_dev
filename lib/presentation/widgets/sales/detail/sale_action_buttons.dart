import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/providers.dart';

// Provider to check if a sale has any returns
final saleHasReturnsProvider = FutureProvider.family<bool, int>((
  ref,
  saleId,
) async {
  // Ensure we listen to updates on the sale (which happen on return creation)
  ref.watch(saleDetailStreamProvider(saleId));

  final repository = ref.read(saleReturnRepositoryProvider);
  final returnedQuantities = await repository.getReturnedQuantities(saleId);
  // Check if any item has a returned quantity > 0
  return returnedQuantities.values.any((qty) => qty > 0);
});

class SaleActionButtons extends ConsumerWidget {
  final Sale sale;

  const SaleActionButtons({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelled = sale.status == SaleStatus.cancelled;
    final isReturned = sale.status == SaleStatus.returned;

    if (isCancelled || isReturned) return const SizedBox.shrink();

    // Check if there are any partial returns
    final hasReturnsAsync = ref.watch(saleHasReturnsProvider(sale.id!));
    final hasReturns = hasReturnsAsync.value ?? false;

    if (hasReturns) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              context.push('/adjustments/return-processing', extra: sale);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_return_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Procesar Devolución',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              _showCancelDialog(context, ref, sale);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cancelar Venta',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, Sale sale) {
    // Use GoRouter to push the cancellation page
    // This ensures consistent transition handling and avoids layout conflicts
    context.push('/sale-cancellation', extra: sale);
  }
}
