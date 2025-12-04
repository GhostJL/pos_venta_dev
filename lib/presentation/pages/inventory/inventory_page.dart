import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/inventory/show_actions_widget.dart';

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

                      return Card(
                        elevation: 0,
                        surfaceTintColor: Theme.of(context).colorScheme.surface,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              context.push('/inventory/detail', extra: item),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Header: producto + acciones
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLeadingIcon(),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product?.name ??
                                                'Producto desconocido',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            warehouse?.name ??
                                                'Almacén desconocido',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (hasAdjustAccess)
                                      IconButton(
                                        onPressed: () =>
                                            showActions(context, ref, item),
                                        icon: const Icon(
                                          Icons.more_vert_rounded,
                                        ),
                                        tooltip: 'Ajustes de inventario',
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                /// Stock y reservado
                                Row(
                                  children: [
                                    _buildBadge(
                                      label:
                                          'Stock: ${item.quantityOnHand.toInt()}',
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.tertiary,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildBadge(
                                      label:
                                          'Reservado: ${item.quantityReserved.toInt()}',
                                      color: Colors.orange,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                /// Ver Lotes button
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      context.push(
                                        '/inventory/lots/${item.productId}/${item.warehouseId}',
                                        extra: {
                                          'productName':
                                              product?.name ?? 'Producto',
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Ver Lotes'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildLeadingIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
