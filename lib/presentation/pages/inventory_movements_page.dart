import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/providers/inventory_movement_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

class InventoryMovementsPage extends ConsumerWidget {
  const InventoryMovementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(inventoryMovementProvider);
    final productsAsync = ref.watch(productNotifierProvider);
    final warehousesAsync = ref.watch(warehouseProvider);
    final usersAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kardex - Movimientos de Inventario'),
        centerTitle: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: movementsAsync.when(
        data: (movements) {
          return productsAsync.when(
            data: (products) {
              return warehousesAsync.when(
                data: (warehouses) {
                  return usersAsync.when(
                    data: (users) {
                      if (movements.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 64,
                                color: AppTheme.textSecondary.withAlpha(100),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No hay movimientos registrados',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Create lookup maps
                      final productMap = {for (var p in products) p.id: p};
                      final warehouseMap = {for (var w in warehouses) w.id: w};
                      final userMap = {for (var u in users) u.id: u};

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: movements.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final movement = movements[index];
                          final product = productMap[movement.productId];
                          final warehouse = warehouseMap[movement.warehouseId];
                          final user = userMap[movement.performedBy];
                          final isIncoming = movement.quantity > 0;
                          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: AppTheme.borders.withAlpha(50),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      (isIncoming
                                              ? AppTheme.success
                                              : AppTheme.error)
                                          .withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isIncoming
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: isIncoming
                                      ? AppTheme.success
                                      : AppTheme.error,
                                ),
                              ),
                              title: Text(
                                product?.name ?? 'Producto desconocido',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${movement.movementType.displayName} - ${warehouse?.name ?? "Almacén desconocido"}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cantidad: ${isIncoming ? "+" : ""}${movement.quantity} | Stock: ${movement.quantityBefore} → ${movement.quantityAfter}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${user?.username ?? "Usuario"} - ${dateFormat.format(movement.movementDate)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) =>
                        Center(child: Text('Error cargando usuarios: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) =>
                    Center(child: Text('Error cargando almacenes: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) =>
                Center(child: Text('Error cargando productos: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error cargando movimientos: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/inventory/movements/new');
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
