import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';
import 'package:posventa/presentation/providers/notification_providers.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/widgets/inventory/card/inventory_card_widget.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(inventoryProvider); // Refresh on entry
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final productsAsync = ref.watch(productNotifierProvider);
    final warehousesAsync = ref.watch(warehousesProvider);

    final hasViewAccess = ref.watch(
      hasPermissionProvider(PermissionConstants.inventoryView),
    );
    final hasAdjustAccess = ref.watch(
      hasPermissionProvider(PermissionConstants.inventoryAdjust),
    );

    if (!hasViewAccess) {
      return const Scaffold(
        body: Center(child: Text('No tienes acceso al inventario')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventario',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final unreadAsync = ref.watch(unreadNotificationsStreamProvider);

              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadAsync.asData?.value.isNotEmpty ?? false,
                  label: Text('${unreadAsync.asData?.value.length ?? 0}'),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                onPressed: () {
                  context.push('/inventory/notifications');
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error al cargar productos: $e')),
        data: (state) {
          final products = state.products;
          return inventoryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox(),
            data: (inventoryList) {
              return warehousesAsync.when(
                loading: () => const SizedBox(),
                error: (e, s) => const SizedBox(),
                data: (warehouses) {
                  final displayItems = <_InventoryDisplayItem>[];
                  final warehouseMap = {for (var w in warehouses) w.id: w};

                  // Iterate PRODUCTS -> VARIANTS (Sales)
                  // If Inventory exists -> Add item with warehouse
                  // If NO Inventory exists -> Add item with 0 stock (and default warehouse concept?)

                  for (var product in products) {
                    if (product.variants == null) continue;

                    for (var variant in product.variants!) {
                      // User requirement: "deben de aparecer las variantes de venta"
                      if (variant.type != VariantType.sales) continue;

                      // Find matching inventory records
                      // Matches if: productId matches AND (variantId matches OR (variantId is null AND product has only 1 variant? - Strict for now))
                      // Let's stick to strict variantId match if possible, BUT since we just added the field
                      // it might be null in DB.
                      // IF we filter by strict variant ID, we see nothing.

                      // Heuristic: If we have inventory for this product, and we haven't assigned it to another variant, maybe show it?
                      // Better approach for "Show Variants":
                      // 1. Strict Match
                      final strictMatches = inventoryList
                          .where(
                            (i) =>
                                i.productId == product.id &&
                                i.variantId == variant.id,
                          )
                          .toList();

                      if (strictMatches.isNotEmpty) {
                        for (var match in strictMatches) {
                          displayItems.add(
                            _InventoryDisplayItem(
                              match,
                              product,
                              variant,
                              warehouseMap[match.warehouseId],
                            ),
                          );
                        }
                      } else {
                        // No strict inventory found.
                        // Does partial inventory exist (Product ID match, Variant ID null)?
                        // If so, we might be hiding it.
                        // BUT for now, let's ensure the VARIANT appears as 0 stock if no strict match.
                        if (warehouses.isNotEmpty) {
                          // E.g. show for the first warehouse or 'Unassigned'
                          // Let's create a Virtual Inventory item with 0 stock for visualization
                          // using the first warehouse ID as a placeholder if available
                          final defaultWarehouseId = warehouses.first.id;
                          displayItems.add(
                            _InventoryDisplayItem(
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

                  // Filtering
                  final filteredItems = displayItems.where((item) {
                    final q = _searchQuery.toLowerCase();
                    return item.product.name.toLowerCase().contains(q) ||
                        item.variant.variantName.toLowerCase().contains(q) ||
                        (item.variant.barcode?.toLowerCase().contains(q) ??
                            false);
                  }).toList();

                  // Stats
                  int lowStockCount = 0;
                  double totalInfo = 0;

                  for (var item in displayItems) {
                    final stock = item.inventory.quantityOnHand;
                    final min =
                        item.inventory.minStock ?? item.variant.stockMin ?? 0.0;
                    if (stock <= min && min > 0) lowStockCount++;
                    totalInfo += stock * item.variant.costPrice;
                  }

                  return Column(
                    children: [
                      // Search
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Buscar nombre, SKU, o escanear...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            suffixIcon: Icon(
                              Icons.qr_code_scanner,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _SummaryCard(
                                    label: 'BAJO STOCK',
                                    value: '$lowStockCount',
                                    subValue: 'Atención requerida',
                                    icon: Icons.warning_amber_rounded,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 12),
                                  _SummaryCard(
                                    label: 'VALORACIÓN',
                                    value: '\$${totalInfo.toStringAsFixed(1)}',
                                    subValue: 'Total en inventario',
                                    icon: Icons.attach_money,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            const Text(
                              'Lista de Stock',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (filteredItems.isEmpty)
                              _buildEmptyState(context, _searchQuery.isNotEmpty)
                            else
                              ...filteredItems.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InventoryCardWidget(
                                    inventory: item.inventory,
                                    product: item.product,
                                    variant: item.variant,
                                    warehouse: item.warehouse,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearch) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isSearch ? 'No se encontraron resultados' : 'No hay inventario',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryDisplayItem {
  final Inventory inventory;
  final Product product;
  final ProductVariant variant;
  final Warehouse? warehouse;

  _InventoryDisplayItem(
    this.inventory,
    this.product,
    this.variant,
    this.warehouse,
  );
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
