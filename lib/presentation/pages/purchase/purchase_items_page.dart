import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/widgets/purchases/items/purchase_items_page/purchase_items_filter_dialog.dart';
import 'package:posventa/presentation/widgets/purchases/items/purchase_items_page/purchase_items_list.dart';
import 'package:posventa/presentation/widgets/purchases/items/purchase_items_page/purchase_items_search_bar.dart';
import 'package:posventa/presentation/providers/purchase_item_providers.dart';

/// Page to display all purchase items across all purchases
/// Useful for POS inventory tracking and purchase history analysis
class PurchaseItemsPage extends ConsumerStatefulWidget {
  const PurchaseItemsPage({super.key});

  @override
  ConsumerState<PurchaseItemsPage> createState() => _PurchaseItemsPageState();
}

class _PurchaseItemsPageState extends ConsumerState<PurchaseItemsPage> {
  String _searchQuery = '';
  String _filterType = 'all'; // all, recent, by_date

  @override
  Widget build(BuildContext context) {
    final purchaseItemsAsync = ref.watch(purchaseItemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos de Compra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(purchaseItemProvider.notifier).refresh();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          PurchaseItemsSearchBar(
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),

          // Items list
          Expanded(
            child: PurchaseItemsList(
              purchaseItemsAsync: purchaseItemsAsync,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => PurchaseItemsFilterDialog(
        currentFilter: _filterType,
        onFilterSelected: (value) {
          setState(() => _filterType = value);
        },
      ),
    );
  }
}
