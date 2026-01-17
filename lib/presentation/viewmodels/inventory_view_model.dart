import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

class InventoryDisplayItem {
  final Inventory inventory;
  final Product product;
  final ProductVariant variant;
  final Warehouse? warehouse;

  InventoryDisplayItem(
    this.inventory,
    this.product,
    this.variant,
    this.warehouse,
  );
}

class InventoryStats {
  final int lowStockCount;
  final double totalValue;
  final int totalItems;

  InventoryStats({
    this.lowStockCount = 0,
    this.totalValue = 0,
    this.totalItems = 0,
  });
}

class InventoryState {
  final List<InventoryDisplayItem> items;
  final InventoryStats stats;
  final bool isLoading;
  final String? error;

  InventoryState({
    this.items = const [],
    required this.stats,
    this.isLoading = false,
    this.error,
  });

  factory InventoryState.initial() {
    return InventoryState(stats: InventoryStats());
  }

  InventoryState copyWith({
    List<InventoryDisplayItem>? items,
    InventoryStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return InventoryState(
      items: items ?? this.items,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Search Query Notifier using Notifier (Riverpod 2.0)
class InventorySearchQueryNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void update(String query) {
    state = query;
  }
}

final inventorySearchQueryProvider =
    NotifierProvider<InventorySearchQueryNotifier, String>(() {
      return InventorySearchQueryNotifier();
    });

final inventoryViewModelProvider = Provider<InventoryState>((ref) {
  final productsAsync = ref.watch(productNotifierProvider);
  final inventoryAsync = ref.watch(inventoryProvider);
  final warehousesAsync = ref.watch(warehousesProvider);
  final searchQuery = ref.watch(inventorySearchQueryProvider).toLowerCase();

  // Handle Loading & Error States
  if (productsAsync.isLoading ||
      inventoryAsync.isLoading ||
      warehousesAsync.isLoading) {
    return InventoryState(stats: InventoryStats(), isLoading: true);
  }

  if (productsAsync.hasError) {
    return InventoryState(
      stats: InventoryStats(),
      error: productsAsync.error.toString(),
    );
  }
  if (inventoryAsync.hasError) {
    return InventoryState(
      stats: InventoryStats(),
      error: inventoryAsync.error.toString(),
    );
  }

  final products = productsAsync.asData?.value ?? [];
  final inventoryList = inventoryAsync.asData?.value ?? [];
  final warehouses = warehousesAsync.asData?.value ?? [];

  final displayItems = <InventoryDisplayItem>[];
  final warehouseMap = {for (var w in warehouses) w.id: w};

  // Logic extracted from InventoryPage
  for (var product in products) {
    if (product.variants == null) continue;

    for (var variant in product.variants!) {
      if (variant.type != VariantType.sales) continue;

      // Filter by Search Query
      if (searchQuery.isNotEmpty) {
        final matchesName =
            product.name.toLowerCase().contains(searchQuery) ||
            variant.variantName.toLowerCase().contains(searchQuery);
        final matchesSku =
            variant.barcode?.toLowerCase().contains(searchQuery) ?? false;
        final matchesExtra =
            variant.additionalBarcodes?.any(
              (code) => code.toLowerCase().contains(searchQuery),
            ) ??
            false;

        if (!matchesName && !matchesSku && !matchesExtra) {
          continue;
        }
      }

      final strictMatches = inventoryList
          .where((i) => i.productId == product.id && i.variantId == variant.id)
          .toList();

      if (strictMatches.isNotEmpty) {
        for (var match in strictMatches) {
          displayItems.add(
            InventoryDisplayItem(
              match,
              product,
              variant,
              warehouseMap[match.warehouseId],
            ),
          );
        }
      } else {
        if (warehouses.isNotEmpty) {
          final defaultWarehouseId = warehouses.first.id;
          displayItems.add(
            InventoryDisplayItem(
              Inventory(
                productId: product.id!,
                warehouseId: defaultWarehouseId!,
                variantId: variant.id,
                quantityOnHand: variant.stock ?? 0,
                minStock: variant.stockMin?.toInt() ?? 0,
                maxStock: variant.stockMax?.toInt() ?? 0,
              ),
              product,
              variant,
              warehouseMap[defaultWarehouseId],
            ),
          );
        }
      }
    }
  }

  // Calculate Stats
  int lowStockCount = 0;
  double totalInfo = 0;

  for (var item in displayItems) {
    final stock = item.inventory.quantityOnHand;
    final min = item.inventory.minStock ?? item.variant.stockMin ?? 0.0;
    if (stock <= min && min > 0) lowStockCount++;
    totalInfo += stock * item.variant.costPrice;
  }

  return InventoryState(
    items: displayItems,
    stats: InventoryStats(
      lowStockCount: lowStockCount,
      totalValue: totalInfo,
      totalItems: displayItems.length,
    ),
    isLoading: false,
  );
});
