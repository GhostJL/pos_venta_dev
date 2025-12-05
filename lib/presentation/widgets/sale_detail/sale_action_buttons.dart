import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/widgets/transaction_void/transaction_void_dialog.dart';

class SaleActionButtons extends ConsumerWidget {
  final Sale sale;

  const SaleActionButtons({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelled = sale.status == SaleStatus.cancelled;
    final isReturned = sale.status == SaleStatus.returned;

    if (isCancelled || isReturned) return const SizedBox.shrink();

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
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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

  Future<void> _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    final reason = await TransactionVoidDialog.show(context, sale);

    if (reason == null || !context.mounted) return;

    try {
      final user = ref.read(authProvider).user;
      if (user == null) throw Exception('Usuario no autenticado');

      await ref
          .read(cancelSaleUseCaseProvider)
          .call(sale.id!, user.id!, reason);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Venta cancelada exitosamente'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
