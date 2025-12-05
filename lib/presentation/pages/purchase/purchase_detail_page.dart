import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';
import 'package:posventa/presentation/widgets/purchases/dialogs/purchase_cancel_dialog.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_info_card.dart';
import 'package:posventa/presentation/widgets/purchases/lists/purchase_items_list.dart';
import 'package:posventa/presentation/widgets/purchases/reception/purchase_reception_dialog.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_totals_card.dart';
import 'package:posventa/domain/entities/purchase_reception_item.dart';

class PurchaseDetailPage extends ConsumerWidget {
  final int purchaseId;

  const PurchaseDetailPage({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseAsync = ref.watch(purchaseByIdProvider(purchaseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Compra'),
        actions: [
          // Show receive button only for pending or partial purchases
          purchaseAsync.when(
            data: (purchase) {
              if (purchase == null) return const SizedBox.shrink();

              final canReceive =
                  purchase.status == PurchaseStatus.pending ||
                  purchase.status == PurchaseStatus.partial;

              final canCancel = purchase.status != PurchaseStatus.cancelled;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canReceive)
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Recibir Compra',
                      onPressed: () => _receivePurchase(context, ref, purchase),
                    ),
                  if (canCancel)
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      offset: const Offset(0, 40),
                      onSelected: (value) {
                        if (value == 'cancel') {
                          _cancelPurchase(context, ref, purchase);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cancelar Compra',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      tooltip: 'Más acciones',
                    ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: purchaseAsync.when(
        data: (purchase) {
          if (purchase == null) {
            return const Center(child: Text('Compra no encontrada'));
          }
          return _PurchaseDetailContent(purchase: purchase);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _cancelPurchase(
    BuildContext context,
    WidgetRef ref,
    Purchase purchase,
  ) async {
    final confirmed = await PurchaseCancelDialog.show(
      context: context,
      purchase: purchase,
    );

    if (confirmed != true) return;

    try {
      final user = ref.read(authProvider).user;
      if (user == null) throw Exception('Usuario no autenticado');

      await ref
          .read(purchaseProvider.notifier)
          .cancelPurchase(purchase.id!, user.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _receivePurchase(
    BuildContext context,
    WidgetRef ref,
    Purchase purchase,
  ) async {
    // Show partial reception dialog
    final itemsToReceive = await showDialog<List<PurchaseReceptionItem>>(
      context: context,
      builder: (context) => PurchaseReceptionDialog(purchase: purchase),
    );

    if (itemsToReceive == null || itemsToReceive.isEmpty) return;

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await ref
          .read(purchaseProvider.notifier)
          .receivePurchase(purchase.id!, itemsToReceive, user.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(width: 8),
                Expanded(child: Text('Recepción registrada exitosamente')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(width: 8),
                Expanded(child: Text('Error al recibir compra: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

class _PurchaseDetailContent extends StatelessWidget {
  final Purchase purchase;

  const _PurchaseDetailContent({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          PurchaseInfoCard(purchase: purchase),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Productos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),

          // Items List
          PurchaseItemsList(items: purchase.items, purchase: purchase),

          // Totals
          PurchaseTotalsCard(
            subtotalCents: purchase.subtotalCents,
            taxCents: purchase.taxCents,
            totalCents: purchase.totalCents,
          ),
        ],
      ),
    );
  }
}
