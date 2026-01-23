import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posventa/core/theme/theme.dart';

enum AdjustmentType { increment, decrement }

class InventoryAdjustmentDialog extends StatefulWidget {
  final String productName;
  final double currentStock;
  final String unitOfMeasure; // 'UNI', 'KG', etc.

  const InventoryAdjustmentDialog({
    super.key,
    required this.productName,
    required this.currentStock,
    this.unitOfMeasure = 'UNI',
  });

  static Future<InventoryAdjustmentResult?> show(
    BuildContext context, {
    required String productName,
    required double currentStock,
    String unitOfMeasure = 'UNI',
  }) {
    return showDialog<InventoryAdjustmentResult>(
      context: context,
      builder: (context) => InventoryAdjustmentDialog(
        productName: productName,
        currentStock: currentStock,
        unitOfMeasure: unitOfMeasure,
      ),
    );
  }

  @override
  State<InventoryAdjustmentDialog> createState() =>
      _InventoryAdjustmentDialogState();
}

class _InventoryAdjustmentDialogState extends State<InventoryAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  AdjustmentType _type = AdjustmentType.increment;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isIncrement = _type == AdjustmentType.increment;
    final actionColor = isIncrement
        ? AppTheme.transactionSuccess
        : colorScheme.error;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Ajuste de Stock', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            widget.productName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Stock Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stock Actual:', style: theme.textTheme.bodyMedium),
                    Text(
                      '${widget.currentStock.toStringAsFixed(2)} ${widget.unitOfMeasure}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Adjustment Type Segmented Control
              SegmentedButton<AdjustmentType>(
                segments: const [
                  ButtonSegment(
                    value: AdjustmentType.increment,
                    label: Text('Entrada'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                  ButtonSegment(
                    value: AdjustmentType.decrement,
                    label: Text('Salida'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<AdjustmentType> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(height: 24),

              // Quantity Input
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Cantidad a ajustar',
                  suffixText: widget.unitOfMeasure,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    isIncrement ? Icons.add : Icons.remove,
                    color: actionColor,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  final qty = double.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Inválido';
                  }
                  if (!isIncrement && qty > widget.currentStock) {
                    return 'Excede stock actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reason Input
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo del ajuste',
                  hintText: 'Ej. Daño, Robo, Conteo Cíclico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.comment_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido para auditoría';
                  }
                  return null;
                },
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: actionColor,
            foregroundColor: Colors.white,
          ),
          onPressed: _submit,
          child: const Text('Confirmar Ajuste'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final quantity = double.parse(_quantityController.text);
      final adjustment = InventoryAdjustmentResult(
        quantity: quantity,
        type: _type,
        reason: _reasonController.text,
      );
      Navigator.pop(context, adjustment);
    }
  }
}

class InventoryAdjustmentResult {
  final double quantity;
  final AdjustmentType type;
  final String reason;

  InventoryAdjustmentResult({
    required this.quantity,
    required this.type,
    required this.reason,
  });
}
