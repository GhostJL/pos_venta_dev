import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/inventory_movement_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/providers/user_provider.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';

class InventoryMovementFormPage extends ConsumerStatefulWidget {
  final InventoryMovement? movement;

  const InventoryMovementFormPage({super.key, this.movement});

  @override
  ConsumerState<InventoryMovementFormPage> createState() =>
      _InventoryMovementFormPageState();
}

class _InventoryMovementFormPageState
    extends ConsumerState<InventoryMovementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _lotNumberController = TextEditingController();

  Product? _selectedProduct;
  Warehouse? _selectedWarehouse;
  Warehouse? _destinationWarehouse;
  MovementType _selectedMovementType = MovementType.adjustment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.movement != null) {
      _quantityController.text = widget.movement!.quantity.abs().toString();
      _reasonController.text = widget.movement!.reason ?? '';
      _lotNumberController.text = widget.movement!.lotNumber ?? '';
      _selectedMovementType = widget.movement!.movementType;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _lotNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);
    final warehousesAsync = ref.watch(warehouseProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.movement == null ? 'Nuevo Movimiento' : 'Editar Movimiento',
        ),
        centerTitle: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: productsAsync.when(
        data: (products) {
          return warehousesAsync.when(
            data: (warehouses) {
              return currentUserAsync.when(
                data: (currentUser) {
                  if (currentUser == null) {
                    return const Center(
                      child: Text('Error: Usuario no autenticado'),
                    );
                  }

                  // Set initial values for edit mode
                  if (widget.movement != null && _selectedProduct == null) {
                    _selectedProduct = products.firstWhere(
                      (p) => p.id == widget.movement!.productId,
                      orElse: () => products.first,
                    );
                    _selectedWarehouse = warehouses.firstWhere(
                      (w) => w.id == widget.movement!.warehouseId,
                      orElse: () => warehouses.first,
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCard(
                            title: 'Información del Movimiento',
                            icon: Icons.info_outline_rounded,
                            children: [
                              _buildDropdown<Product>(
                                label: 'Producto',
                                value: _selectedProduct,
                                items: products,
                                itemLabel: (p) => p.name,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProduct = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Seleccione un producto';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown<Warehouse>(
                                label: 'Almacén',
                                value: _selectedWarehouse,
                                items: warehouses,
                                itemLabel: (w) => w.name,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWarehouse = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Seleccione un almacén';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildMovementTypeSelector(),
                              const SizedBox(height: 16),
                              if (_selectedMovementType ==
                                  MovementType.transferOut) ...[
                                _buildDropdown<Warehouse>(
                                  label: 'Almacén Destino',
                                  value: _destinationWarehouse,
                                  items: warehouses
                                      .where(
                                        (w) => w.id != _selectedWarehouse?.id,
                                      )
                                      .toList(),
                                  itemLabel: (w) => w.name,
                                  onChanged: (value) {
                                    setState(() {
                                      _destinationWarehouse = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (_selectedMovementType ==
                                            MovementType.transferOut &&
                                        value == null) {
                                      return 'Seleccione un almacén destino';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCard(
                            title: 'Detalles',
                            icon: Icons.edit_note_rounded,
                            children: [
                              TextFormField(
                                controller: _quantityController,
                                decoration: InputDecoration(
                                  labelText: 'Cantidad',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    _isIncomingMovement()
                                        ? Icons.add_circle_outline
                                        : Icons.remove_circle_outline,
                                    color: _isIncomingMovement()
                                        ? AppTheme.success
                                        : AppTheme.error,
                                  ),
                                  helperText: _isIncomingMovement()
                                      ? 'Entrada de inventario'
                                      : 'Salida de inventario',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese la cantidad';
                                  }
                                  final quantity = double.tryParse(value);
                                  if (quantity == null || quantity <= 0) {
                                    return 'Ingrese una cantidad válida';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _lotNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Número de Lote (Opcional)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.qr_code_rounded),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _reasonController,
                                decoration: const InputDecoration(
                                  labelText: 'Motivo/Razón',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.comment_rounded),
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (_selectedMovementType ==
                                          MovementType.adjustment &&
                                      (value == null || value.isEmpty)) {
                                    return 'El motivo es requerido para ajustes';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _saveMovement(currentUser.id!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    widget.movement == null
                                        ? 'Registrar Movimiento'
                                        : 'Actualizar Movimiento',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) =>
                Center(child: Text('Error cargando almacenes: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error cargando productos: $e')),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
        border: Border.all(color: AppTheme.borders.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildMovementTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Movimiento',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MovementType.values.map((type) {
            final isSelected = _selectedMovementType == type;
            return ChoiceChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedMovementType = type;
                  });
                }
              },
              selectedColor: AppTheme.primary.withAlpha(50),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isIncomingMovement() {
    return _selectedMovementType == MovementType.purchase ||
        _selectedMovementType == MovementType.transferIn ||
        _selectedMovementType == MovementType.returnMovement;
  }

  Future<void> _saveMovement(int userId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProduct == null || _selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un producto y almacén'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current inventory
      final inventoryList = await ref.read(
        inventoryByProductProvider(_selectedProduct!.id!).future,
      );

      final currentInventory = inventoryList.firstWhere(
        (inv) => inv.warehouseId == _selectedWarehouse!.id,
        orElse: () => throw Exception(
          'No se encontró inventario para este producto y almacén',
        ),
      );

      final quantity = double.parse(_quantityController.text);
      final isIncoming = _isIncomingMovement();
      final signedQuantity = isIncoming ? quantity : -quantity;

      final quantityBefore = currentInventory.quantityOnHand;
      final quantityAfter = quantityBefore + signedQuantity;

      if (quantityAfter < 0) {
        throw Exception('Stock insuficiente. Stock actual: $quantityBefore');
      }

      final movement = InventoryMovement(
        id: widget.movement?.id,
        productId: _selectedProduct!.id!,
        warehouseId: _selectedWarehouse!.id!,
        movementType: _selectedMovementType,
        quantity: signedQuantity,
        quantityBefore: quantityBefore,
        quantityAfter: quantityAfter,
        lotNumber: _lotNumberController.text.isEmpty
            ? null
            : _lotNumberController.text,
        reason: _reasonController.text.isEmpty ? null : _reasonController.text,
        performedBy: userId,
        movementDate: DateTime.now(),
      );

      if (widget.movement == null) {
        if (_selectedMovementType == MovementType.adjustment ||
            _selectedMovementType == MovementType.damage) {
          await ref
              .read(inventoryMovementProvider.notifier)
              .adjustInventory(movement);
        } else if (_selectedMovementType == MovementType.transferOut) {
          if (_destinationWarehouse == null) {
            throw Exception('Seleccione un almacén de destino');
          }
          if (_destinationWarehouse!.id == _selectedWarehouse!.id) {
            throw Exception(
              'El almacén de destino debe ser diferente al de origen',
            );
          }

          await ref
              .read(inventoryMovementProvider.notifier)
              .transferInventory(
                fromWarehouseId: _selectedWarehouse!.id!,
                toWarehouseId: _destinationWarehouse!.id!,
                productId: _selectedProduct!.id!,
                quantity: movement.quantity.abs(),
                userId: userId,
                reason: movement.reason,
              );
        } else {
          await ref
              .read(inventoryMovementProvider.notifier)
              .addMovement(movement);
        }

        // Inventory update is now handled by the use case/repository transactionally.
        // We don't need to manually update inventory provider here.
        // But we might want to refresh the inventory list.
        ref.invalidate(inventoryProvider);
        ref.invalidate(inventoryByProductProvider);
      } else {
        await ref
            .read(inventoryMovementProvider.notifier)
            .modifyMovement(movement);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.movement == null
                  ? 'Movimiento registrado correctamente'
                  : 'Movimiento actualizado correctamente',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
