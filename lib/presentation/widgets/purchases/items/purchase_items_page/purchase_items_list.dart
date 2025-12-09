import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/widgets/purchases/items/purchase_items_page/purchase_item_card.dart';
import 'package:posventa/presentation/providers/purchase_item_providers.dart';

class PurchaseItemsList extends ConsumerWidget {
  final AsyncValue<List<PurchaseItem>> purchaseItemsAsync;
  final String searchQuery;

  const PurchaseItemsList({
    super.key,
    required this.purchaseItemsAsync,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return purchaseItemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(
            context,
            Icons.inventory_2_outlined,
            'No hay artículos de compra registrados',
          );
        }

        final filteredItems = items.where((item) {
          if (searchQuery.isEmpty) return true;
          return (item.productName ?? '').toLowerCase().contains(searchQuery);
        }).toList();

        if (filteredItems.isEmpty) {
          return _buildEmptyState(
            context,
            Icons.search_off,
            'No se encontraron resultados',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return PurchaseItemCard(item: item);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(purchaseItemProvider.notifier).refresh();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
