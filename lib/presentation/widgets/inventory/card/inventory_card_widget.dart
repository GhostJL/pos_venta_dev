import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';

class InventoryCardWidget extends ConsumerWidget {
  final Inventory item;
  final Product? product;
  final Warehouse? warehouse;

  const InventoryCardWidget({
    super.key,
    required this.item,
    required this.product,
    required this.warehouse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/inventory/detail', extra: item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header: producto + acciones
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeadingIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?.name ?? 'Producto desconocido',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          warehouse?.name ?? 'Almacén desconocido',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Stock y reservado
              Row(
                children: [
                  _buildBadge(
                    label: 'Stock: ${item.quantityOnHand.toInt()}',
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    label: 'Reservado: ${item.quantityReserved.toInt()}',
                    color: AppTheme.transactionPending,
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
                      extra: {'productName': product?.name ?? 'Producto'},
                    );
                  },
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: const Text('Ver Lotes'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar inventario'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este registro de inventario? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (item.id == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: El ID del inventario es nulo'),
            ),
          );
        }
        return;
      }
      if (context.mounted) {
        try {
          await ref.read(inventoryProvider.notifier).deleteInventory(item.id!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inventario eliminado correctamente'),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al eliminar inventario: $e')),
            );
          }
        }
      }
    }
  }
}

Widget _buildLeadingIcon(BuildContext context) {
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
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}
