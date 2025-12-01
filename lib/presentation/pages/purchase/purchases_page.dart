import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/purchase_filter_chip_provider.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/purchase/chips/purchase_filter_chips.dart';
import 'package:posventa/presentation/widgets/purchase/empty_purchases_view.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_card_widget.dart';

class PurchasesPage extends ConsumerWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchaseProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );
    final selectedFilter = ref.watch(purchaseFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      floatingActionButton: hasManagePermission
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/purchases/new'),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Nueva Compra'),
              tooltip: 'Crear Nueva Compra',
            )
          : null,
      body: Column(
        children: [
          PurchaseFilterChips(selectedFilter: selectedFilter),
          const Divider(height: 1),
          Expanded(
            child: purchasesAsync.when(
              data: (purchases) {
                final filtered = selectedFilter == null
                    ? purchases
                    : purchases
                          .where((p) => p.status == selectedFilter)
                          .toList();

                if (filtered.isEmpty) {
                  return const EmptyPurchasesView();
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(purchaseProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => PurchaseCard(purchase: filtered[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
