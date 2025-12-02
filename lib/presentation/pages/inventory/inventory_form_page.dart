import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';

import 'package:posventa/presentation/providers/product_provider.dart';

class InventoryFormPage extends ConsumerStatefulWidget {
  final Inventory? inventory;

  const InventoryFormPage({super.key, this.inventory});

  @override
  ConsumerState<InventoryFormPage> createState() => _InventoryFormPageState();
}

class _InventoryFormPageState extends ConsumerState<InventoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late int? _selectedProductId;
  late int? _selectedWarehouseId;
  late TextEditingController _quantityController;
  late TextEditingController _minStockController;
  late TextEditingController _maxStockController;
  late TextEditingController _lotNumberController;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.inventory?.productId;
    _selectedWarehouseId = widget.inventory?.warehouseId;
    _quantityController = TextEditingController(
      text: widget.inventory?.quantityOnHand.toString() ?? '0',
    );
    _minStockController = TextEditingController(
      text: widget.inventory?.minStock?.toString() ?? '',
    );
    _maxStockController = TextEditingController(
      text: widget.inventory?.maxStock?.toString() ?? '',
    );
    _lotNumberController = TextEditingController(
      // text: widget.inventory?.lotNumber ?? '',
      text: '',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _lotNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);
    final warehousesAsync = ref.watch(warehousesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.inventory == null ? 'Nuevo Inventario' : 'Editar Inventario',
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Dropdown
              productsAsync.when(
                data: (products) => DropdownButtonFormField<int>(
                  initialValue: _selectedProductId,
                  decoration: const InputDecoration(
                    labelText: 'Producto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2_rounded),
                  ),
                  items: products.map((p) {
                    return DropdownMenuItem(value: p.id, child: Text(p.name));
                  }).toList(),
                  onChanged: widget.inventory == null
                      ? (val) => setState(() => _selectedProductId = val)
                      : null, // Disable if editing
                  validator: (val) =>
                      val == null ? 'Seleccione un producto' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),

              // Warehouse Dropdown
              warehousesAsync.when(
                data: (warehouses) => DropdownButtonFormField<int>(
                  initialValue: _selectedWarehouseId,
                  decoration: const InputDecoration(
                    labelText: 'Almacén',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warehouse_rounded),
                  ),
                  items: warehouses.map((w) {
                    return DropdownMenuItem(value: w.id, child: Text(w.name));
                  }).toList(),
                  onChanged: widget.inventory == null
                      ? (val) => setState(() => _selectedWarehouseId = val)
                      : null, // Disable if editing
                  validator: (val) =>
                      val == null ? 'Seleccione un almacén' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),

              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Disponible',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Ingrese la cantidad';
                  if (double.tryParse(val) == null) return 'Cantidad inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Min/Max Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Mínimo',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxStockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Máximo',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lot Number
              // TextFormField(
              //   controller: _lotNumberController,
              //   decoration: const InputDecoration(
              //     labelText: 'Número de Lote (Opcional)',
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.qr_code_rounded),
              //   ),
              // ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveInventory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveInventory() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate that product and warehouse are selected
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un producto')),
      );
      return;
    }

    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un almacén')),
      );
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final minStock = int.tryParse(_minStockController.text);
    final maxStock = int.tryParse(_maxStockController.text);

    final inventory = Inventory(
      id: widget.inventory?.id,
      productId: _selectedProductId!,
      warehouseId: _selectedWarehouseId!,
      quantityOnHand: quantity,
      quantityReserved: widget.inventory?.quantityReserved ?? 0,
      minStock: minStock,
      maxStock: maxStock,
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.inventory == null) {
        await ref.read(inventoryProvider.notifier).addInventory(inventory);
      } else {
        await ref.read(inventoryProvider.notifier).updateInventory(inventory);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error al guardar: $e';

        // Provide more specific error messages
        if (e.toString().contains('FOREIGN KEY')) {
          if (e.toString().contains('product_id')) {
            errorMessage =
                'Error: El producto seleccionado no existe en la base de datos. Por favor, cree el producto primero.';
          } else if (e.toString().contains('warehouse_id')) {
            errorMessage =
                'Error: El almacén seleccionado no existe en la base de datos. Por favor, cree el almacén primero.';
          } else {
            errorMessage =
                'Error: Violación de clave foránea. Verifique que el producto y almacén existan.';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
