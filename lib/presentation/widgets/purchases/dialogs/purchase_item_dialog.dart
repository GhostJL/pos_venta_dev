import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/core/utils/purchase_calculations.dart';
import 'package:posventa/core/utils/purchase_validators.dart';

/// Unified dialog for adding or editing purchase items
class PurchaseItemDialog extends ConsumerStatefulWidget {
  final Product product;
  final ProductVariant? variant;
  final int warehouseId;
  final PurchaseItem? existingItem;

  const PurchaseItemDialog({
    super.key,
    required this.product,
    this.variant,
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
      // If variant is present, convert base units to pack units for display
      final displayQuantity = widget.variant != null
          ? widget.existingItem!.quantity / widget.variant!.quantity
          : widget.existingItem!.quantity;

      // For variants, calculate pack cost from the precise subtotal
      // to avoid rounding errors from unitCost
      final displayCost = widget.variant != null
          ? widget.existingItem!.subtotal / displayQuantity
          : widget.existingItem!.unitCost;

      _quantityController = TextEditingController(
        text: displayQuantity.toString(),
      );
      _costController = TextEditingController(
        text: displayCost.toStringAsFixed(2),
      );
    } else {
      _quantityController = TextEditingController(text: '1');

      // If variant is present, show pack cost. Otherwise show unit cost.
      final initialCost = widget.variant != null
          ? (widget.variant!.costPriceCents / 100)
          : (widget.product.costPriceCents / 100);

      _costController = TextEditingController(
        text: initialCost.toStringAsFixed(2),
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

    final inputQuantity = double.parse(_quantityController.text);
    final inputCost = double.parse(_costController.text);

    // Convert back to base units if variant is present
    final finalQuantity = widget.variant != null
        ? inputQuantity * widget.variant!.quantity
        : inputQuantity;

    // If variant is present, inputCost is the PACK cost.
    // We need to calculate the unit cost.
    // To avoid precision loss, we should ideally pass the pack cost to createPurchaseItem
    // or calculate unitCost with high precision.
    // 160 / 12 = 13.3333333333...

    final finalUnitCost = widget.variant != null
        ? inputCost / widget.variant!.quantity
        : inputCost;

    final item = PurchaseCalculations.createPurchaseItem(
      product: widget.product,
      variant: widget.variant,
      quantity: finalQuantity,
      unitCost: finalUnitCost,
      existingItem: widget.existingItem,
    );

    context.pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing
            ? 'Editar ${widget.variant != null ? "${widget.product.name} (${widget.variant!.description})" : widget.product.name}'
            : 'Agregar ${widget.variant != null ? "${widget.product.name} (${widget.variant!.description})" : widget.product.name}',
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Costo anterior: \$${(widget.variant != null ? (widget.variant!.costPriceCents / 100) : (widget.product.costPriceCents / 100)).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
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
