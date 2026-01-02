import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/services/label_service.dart';

class LabelPrintDialog extends StatefulWidget {
  final Product product;

  const LabelPrintDialog({super.key, required this.product});

  @override
  State<LabelPrintDialog> createState() => _LabelPrintDialogState();
}

class _LabelPrintDialogState extends State<LabelPrintDialog> {
  // Map of Variant ID -> Quantity. For simple products, acts as single entry with key 0 or null.
  final Map<int, int> _variantQuantities = {};
  int _simpleQuantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.isVariableProduct) {
      for (final variant in widget.product.variants!) {
        // Initialize with 0
        _variantQuantities[variant.id ?? 0] = 0;
      }
    }
  }

  bool get _isSimple => !widget.product.isVariableProduct;

  int get _totalLabels {
    if (_isSimple) return _simpleQuantity;
    return _variantQuantities.values.fold(0, (sum, q) => sum + q);
  }

  void _updateQuantity(int variantId, int delta) {
    setState(() {
      final current = _variantQuantities[variantId] ?? 0;
      final newQ = (current + delta).clamp(0, 999);
      _variantQuantities[variantId] = newQ;
    });
  }

  void _selectAll() {
    setState(() {
      final allSelected = _variantQuantities.values.every((q) => q > 0);
      for (final key in _variantQuantities.keys) {
        _variantQuantities[key] = allSelected ? 0 : 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Imprimir Etiquetas'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isSimple)
              _buildSimpleInterface(theme)
            else
              _buildVariableInterface(theme),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _totalLabels > 0
              ? () {
                  final requests = <LabelPrintRequest>[];
                  if (_isSimple) {
                    requests.add(
                      LabelPrintRequest(
                        product: widget.product,
                        quantity: _simpleQuantity,
                      ),
                    );
                  } else {
                    widget.product.variants?.forEach((variant) {
                      final q = _variantQuantities[variant.id ?? 0] ?? 0;
                      if (q > 0) {
                        requests.add(
                          LabelPrintRequest(
                            product: widget.product,
                            variant: variant,
                            quantity: q,
                          ),
                        );
                      }
                    });
                  }
                  debugPrint('Printing ${requests.length} requests');
                  Navigator.pop(context, requests);
                }
              : null,
          icon: const Icon(Icons.print),
          label: Text('Imprimir ($_totalLabels)'),
        ),
      ],
    );
  }

  Widget _buildSimpleInterface(ThemeData theme) {
    return Row(
      children: [
        const Text('Cantidad de copias:'),
        const Spacer(),
        IconButton(
          onPressed: () => setState(() {
            if (_simpleQuantity > 1) _simpleQuantity--;
          }),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$_simpleQuantity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => setState(() {
            _simpleQuantity++;
          }),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildVariableInterface(ThemeData theme) {
    // Check if all areselected
    final allSelected =
        _variantQuantities.isNotEmpty &&
        _variantQuantities.values.every((q) => q > 0);

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with "Select All"
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Text(
                  'Variantes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectAll,
                  child: Text(
                    allSelected ? 'Deseleccionar' : 'Seleccionar todo',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.product.variants?.length ?? 0,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final variant = widget.product.variants![index];
                final qty = _variantQuantities[variant.id ?? 0] ?? 0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    variant.variantName,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    variant.barcode ?? 'Sin código',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _updateQuantity(variant.id ?? 0, -1),
                        icon: Icon(
                          qty == 0
                              ? Icons.check_box_outline_blank
                              : Icons.remove_circle_outline,
                          color: qty == 0 ? theme.colorScheme.outline : null,
                        ),
                        tooltip: qty == 0 ? 'Seleccionar (1)' : 'Disminuir',
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: qty > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: qty > 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _updateQuantity(variant.id ?? 0, 1),
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Aumentar',
                      ),
                    ],
                  ),
                  onTap: () {
                    // Toggle logic on tap
                    _updateQuantity(variant.id ?? 0, qty > 0 ? -qty : 1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
