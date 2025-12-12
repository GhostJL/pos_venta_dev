import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/inventory/adjustments/show_actions_widget.dart';

import 'package:posventa/presentation/widgets/inventory/card/inventory_card_widget.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(inventoryProvider);
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
        title: const Text('Inventario'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (hasAdjustAccess)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Agregar inventario',
              onPressed: () => context.push('/inventory/form'),
            ),
        ],
      ),
      body: inventoryAsync.when(
        data: (inventoryList) {
          return productsAsync.when(
            data: (products) {
              return warehousesAsync.when(
                data: (warehouses) {
                  if (inventoryList.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  final productMap = {for (var p in products) p.id: p};
                  final warehouseMap = {for (var w in warehouses) w.id: w};

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: inventoryList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = inventoryList[index];
                      final product = productMap[item.productId];
                      final warehouse = warehouseMap[item.warehouseId];

                      return InventoryCardWidget(
                        item: item,
                        product: product,
                        warehouse: warehouse,
                        hasAdjustAccess: hasAdjustAccess,
                        showActions: () => showActions(context, ref, item),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error cargando almacenes: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Error cargando productos: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error cargando inventario: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 72,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay inventario registrado',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
