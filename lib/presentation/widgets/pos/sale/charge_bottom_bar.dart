import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/cart_item_widget.dart';

class ChargeBottomBar extends StatelessWidget {
  final List<SaleItem> cartItems;
  final double total;
  final VoidCallback? onCharge;
  final Function(SaleItem) onRemoveItem;
  final Function(SaleItem, double) onUpdateQuantity;

  const ChargeBottomBar({
    super.key,
    required this.cartItems,
    required this.total,
    this.onCharge,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
  });

  void _showCartItemsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final posState = ref.watch(pOSProvider);
            final currentItems = posState.cart;

            return Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Productos en Carrito',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: currentItems.isEmpty
                        ? Center(
                            child: Text(
                              'El carrito está vacío',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : ListView.separated(
                            itemCount: currentItems.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final item = currentItems[index];
                              return GestureDetector(
                                onLongPress: () {
                                  _showQuantityDialog(context, item);
                                },
                                child: CartItemWidget(
                                  productName: item.productName,
                                  variantDescription: item.variantDescription,
                                  quantity: item.quantity,
                                  unitPrice: item.unitPrice,
                                  tax: item.tax,
                                  total: item.total,
                                  onPressedRemove: () => onRemoveItem(item),
                                  onTapLessProduct: () {
                                    if (item.quantity > 1) {
                                      onUpdateQuantity(item, item.quantity - 1);
                                    } else {
                                      onRemoveItem(item);
                                    }
                                  },
                                  onTapMoreProduct: () {
                                    onUpdateQuantity(item, item.quantity + 1);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showQuantityDialog(BuildContext context, SaleItem item) {
    final controller = TextEditingController(
      text: item.quantity.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modificar Cantidad'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Cantidad'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newQuantity = double.tryParse(controller.text);
                if (newQuantity != null && newQuantity > 0) {
                  onUpdateQuantity(item, newQuantity);
                  Navigator.pop(context); // Close dialog
                  // Note: Modal stays open because it's a separate route
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemCount = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.quantity * item.unitsPerPack,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary Row
          InkWell(
            onTap: () => _showCartItemsModal(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${itemCount.toStringAsFixed(0)} artículos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_up,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const Spacer(),
                  Text(
                    'Total: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Charge Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onCharge,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Matches design
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Row(
                children: [
                  const Text(
                    'Cobrar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
