import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/product_grid/product_grid_item_model.dart';

class ProductQuantityDialog extends ConsumerStatefulWidget {
  final ProductGridItem item;

  const ProductQuantityDialog({super.key, required this.item});

  @override
  ConsumerState<ProductQuantityDialog> createState() =>
      _ProductQuantityDialogState();
}

class _ProductQuantityDialogState extends ConsumerState<ProductQuantityDialog> {
  late TextEditingController _controller;
  double _quantity = 0;

  @override
  void initState() {
    super.initState();
    final cartItems = ref.read(pOSProvider).cart;
    final existingItem = cartItems
        .where(
          (i) =>
              i.productId == widget.item.product.id &&
              i.variantId == widget.item.variant?.id,
        )
        .firstOrNull;

    _quantity = existingItem?.quantity ?? 0;
    _controller = TextEditingController(text: _quantity.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuantity(double delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(0, 9999);
      _controller.text = _quantity.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.item.product.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.item.variant != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.item.variant!.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.remove,
                  onPressed: () => _updateQuantity(-1),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (value) {
                      final val = double.tryParse(value);
                      if (val != null) {
                        _quantity = val;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.add,
                  isBlue: true,
                  onPressed: () => _updateQuantity(1),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(pOSProvider.notifier)
                          .removeFromCart(
                            widget.item.product.id!,
                            variantId: widget.item.variant?.id,
                          );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final error = await ref
                          .read(pOSProvider.notifier)
                          .setQuantity(
                            widget.item.product,
                            _quantity,
                            variant: widget.item.variant,
                          );
                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error)));
                      } else if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Actualizar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isBlue = false,
  }) {
    return Material(
      color: isBlue
          ? Theme.of(context).colorScheme.primary
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: isBlue
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
