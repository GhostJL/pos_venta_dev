import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/cart_item_widget.dart';
import 'package:posventa/presentation/widgets/pos/customer_selection_widget.dart';
import 'package:posventa/presentation/widgets/pos/payment/payment_dialog.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class CartSection extends ConsumerWidget {
  final bool isMobile;

  const CartSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posState = ref.watch(pOSProvider);
    final posNotifier = ref.read(pOSProvider.notifier);
    final hasVoidPermission = ref.watch(
      hasPermissionProvider(PermissionConstants.posVoidItem),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: isMobile
            ? null
            : Border(
                left: BorderSide(color: Theme.of(context).colorScheme.outline),
                top: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
      ),
      child: Column(
        children: [
          // Customer Selection and Clear Cart
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomerSelectionWidget(
                    posState: posState.selectedCustomer != null
                        ? '${posState.selectedCustomer!.firstName} ${posState.selectedCustomer!.lastName}'
                        : 'Cliente General',
                  ),
                ),
                if (posState.cart.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Limpiar Carrito'),
                          content: const Text(
                            '¿Estás seguro de que deseas eliminar todos los productos del carrito?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCELAR'),
                            ),
                            TextButton(
                              onPressed: () {
                                posNotifier.clearCart();
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                              child: const Text('LIMPIAR'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete_sweep,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: 'Limpiar Carrito',
                  ),
                ],
              ],
            ),
          ),
          // Cart Items List
          Expanded(
            child: posState.cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Carrito vacío',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: posState.cart.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    itemBuilder: (context, index) {
                      final item = posState.cart[index];
                      return CartItemWidget(
                        productName: item.productName,
                        onPressedRemove: () {
                          posNotifier.removeFromCart(
                            item.productId,
                            variantId: item.variantId,
                          );
                        },
                        onTapLessProduct: () {
                          posNotifier.updateQuantity(
                            item.productId,
                            item.quantity - 1,
                          );
                        },
                        onTapMoreProduct: () async {
                          final error = await posNotifier.updateQuantity(
                            item.productId,
                            item.quantity + 1,
                          );
                          if (error != null && context.mounted) {
                            _showStockError(context, error);
                          }
                        },
                        quantity: item.quantity,
                        unitPrice: item.unitPrice,
                        tax: item.tax,
                        total: item.total,
                      );
                    },
                  ),
          ),

          // Totals and Checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTotalRow('Subtotal', posState.subtotal),
                _buildTotalRow('Impuestos', posState.tax),
                if (posState.discount > 0)
                  _buildTotalRow(
                    'Descuento',
                    posState.discount,
                    isDiscount: true,
                  ),
                const Divider(height: 24),
                _buildTotalRow(
                  'TOTAL',
                  posState.total,
                  isBold: true,
                  fontSize: 20,
                ),
                const SizedBox(height: 16),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: posState.cart.isEmpty
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => const PaymentDialog(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'PROCESAR PAGO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 14,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: isDiscount ? AppTheme.transactionSuccess : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showStockError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Theme.of(context).colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 16,
          right: 16,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
