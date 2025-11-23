import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/core/utils/purchase_calculations.dart';
import 'package:posventa/core/utils/purchase_validators.dart';

/// Unified dialog for adding or editing purchase items
class PurchaseItemDialog extends ConsumerStatefulWidget {
  final Product product;
  final int warehouseId;
  final PurchaseItem? existingItem;

  const PurchaseItemDialog({
    super.key,
    required this.product,
    required this.warehouseId,
    this.existingItem,
  });

  @override
  ConsumerState<PurchaseItemDialog> createState() => _PurchaseItemDialogState();
}

class _PurchaseItemDialogState extends ConsumerState<PurchaseItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _costController;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers based on whether we're editing or adding
    if (_isEditing) {
      _quantityController = TextEditingController(
        text: widget.existingItem!.quantity.toString(),
      );
      _costController = TextEditingController(
        text: widget.existingItem!.unitCost.toStringAsFixed(2),
      );
    } else {
      _quantityController = TextEditingController(text: '1');
      _costController = TextEditingController(
        text: (widget.product.costPriceCents / 100).toStringAsFixed(2),
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.parse(_quantityController.text);
    final cost = double.parse(_costController.text);

    final item = PurchaseCalculations.createPurchaseItem(
      product: widget.product,
      quantity: quantity,
      unitCost: cost,
      existingItem: widget.existingItem,
    );

    context.pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing
            ? 'Editar ${widget.product.name}'
            : 'Agregar ${widget.product.name}',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show cost reference only when adding (not editing)
              if (!_isEditing) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Costo anterior: \$${(widget.product.costPriceCents / 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Quantity field
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: PurchaseValidators.validateQuantity,
              ),
              const SizedBox(height: 16),

              // Cost field
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Costo Unitario',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: PurchaseValidators.validateCost,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(_isEditing ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }
}
