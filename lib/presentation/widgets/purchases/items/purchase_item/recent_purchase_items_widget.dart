import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/purchase_item_providers.dart';
import 'package:posventa/presentation/widgets/purchases/items/purchase_item/purchase_item_list_tile.dart';

/// Widget to display recent purchase items
/// Useful for POS dashboard quick access
class RecentPurchaseItemsWidget extends ConsumerWidget {
  final int limit;
  final bool showTitle;

  const RecentPurchaseItemsWidget({
    super.key,
    this.limit = 10,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentItemsAsync = ref.watch(
      recentPurchaseItemsProvider(limit: limit),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Artículos Recientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
        recentItemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No hay artículos recientes',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return PurchaseItemListTile(
                  item: items[index],
                  showActions: false,
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Error al cargar artículos: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
