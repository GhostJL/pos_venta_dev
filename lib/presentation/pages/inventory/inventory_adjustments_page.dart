import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/inventory_adjustment_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/widgets/inventory/adjustments/adjustment_item_card.dart';

class InventoryAdjustmentsPage extends ConsumerWidget {
  const InventoryAdjustmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adjustmentItems = ref.watch(inventoryAdjustmentProvider);
    final notifier = ref.read(inventoryAdjustmentProvider.notifier);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de Inventario'),
        actions: [
          if (adjustmentItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                notifier.clear();
              },
              tooltip: 'Limpiar todo',
            ),
        ],
      ),
      body: adjustmentItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_add,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ajustes pendientes',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddProductDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Producto'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: adjustmentItems.length,
              itemBuilder: (context, index) {
                final item = adjustmentItems[index];
                return AdjustmentItemCard(
                  item: item,
                  onRemove: () => notifier.removeItem(index),
                  onQuantityChanged: (value) {
                    // Logic to update quantity if we had a slider or direct input in card
                  },
                  onReasonChanged: (value) {
                    notifier.updateItem(index, item.copyWith(reason: value));
                  },
                );
              },
            ),
      floatingActionButton: adjustmentItems.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'add',
                  onPressed: () => _showAddProductDialog(context, ref),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  heroTag: 'save',
                  onPressed: () async {
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error: Usuario no autenticado'),
                        ),
                      );
                      return;
                    }
                    try {
                      await notifier.submitAdjustments(user.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ajustes procesados correctamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al procesar ajustes: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  label: const Text('Procesar'),
                  icon: const Icon(Icons.save),
                ),
              ],
            )
          : null,
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _AddProductDialog(),
    );
  }
}

class _AddProductDialog extends ConsumerStatefulWidget {
  const _AddProductDialog();

  @override
  ConsumerState<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<_AddProductDialog> {
  Product? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isAdjustmentPositive = true;
  List<Product> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final results = await ref.read(searchProductsProvider).call(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Ajuste'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedProduct == null) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar producto',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                onChanged: (value) {
                  _searchProducts(value);
                },
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Stock: ${product.stock}'),
                        onTap: () {
                          setState(() {
                            _selectedProduct = product;
                            _searchResults = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ] else ...[
              ListTile(
                title: Text(_selectedProduct!.name),
                subtitle: Text('Stock Actual: ${_selectedProduct!.stock}'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedProduct = null),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        helperText: 'Cantidad a ajustar',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ToggleButtons(
                    isSelected: [_isAdjustmentPositive, !_isAdjustmentPositive],
                    onPressed: (index) {
                      setState(() {
                        _isAdjustmentPositive = index == 0;
                      });
                    },
                    children: const [
                      Icon(Icons.add, color: Colors.green),
                      Icon(Icons.remove, color: Colors.red),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  hintText: 'Ej. Daño, Caducidad, Inventario Inicial',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        if (_selectedProduct != null)
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(_quantityController.text);
              if (quantity == null || quantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese una cantidad válida')),
                );
                return;
              }

              final finalQuantity = _isAdjustmentPositive
                  ? quantity
                  : -quantity;

              // Default warehouse ID 1 for now
              const warehouseId = 1;

              final warehouses = await ref
                  .read(getAllWarehousesProvider)
                  .call();
              if (warehouses.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No hay sucursales configuradas'),
                    ),
                  );
                }
                return;
              }
              final warehouse = warehouses.first; // Default to first warehouse

              // Get current stock for this warehouse specifically
              final inventoryList = await ref
                  .read(getInventoryByProductProvider)
                  .call(_selectedProduct!.id!);
              final currentStock = inventoryList
                  .where((inv) => inv.warehouseId == warehouse.id)
                  .fold(0.0, (sum, inv) => sum + inv.quantityOnHand);

              final item = AdjustmentItem(
                product: _selectedProduct!,
                warehouse: warehouse,
                quantity: finalQuantity,
                currentStock: currentStock,
                reason: _reasonController.text,
                type: _isAdjustmentPositive
                    ? MovementType.adjustment
                    : MovementType.damage,
              );

              ref.read(inventoryAdjustmentProvider.notifier).addItem(item);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
      ],
    );
  }
}
