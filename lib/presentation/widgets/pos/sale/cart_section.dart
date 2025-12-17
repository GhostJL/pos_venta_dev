import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/pages/pos_sale/widgets/cart_item_card.dart';
import 'package:posventa/presentation/widgets/pos/consumer_selection_dialog_widget.dart';
import 'package:posventa/presentation/widgets/pos/payment/payment_dialog.dart';

class CartSection extends ConsumerWidget {
  final bool isMobile;

  const CartSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch relevant state
    final cart = ref.watch(pOSProvider.select((s) => s.cart));
    final subtotal = ref.watch(pOSProvider.select((s) => s.subtotal));
    final total = ref.watch(pOSProvider.select((s) => s.total));
    final discount = ref.watch(pOSProvider.select((s) => s.discount));
    final taxBreakdown = ref.watch(posTaxBreakdownProvider);

    final posNotifier = ref.read(pOSProvider.notifier);

    // Determine selected customer for display
    final selectedCustomer = ref.watch(
      pOSProvider.select((state) => state.selectedCustomer),
    );
    final customerName = selectedCustomer != null
        ? '${selectedCustomer.firstName} ${selectedCustomer.lastName}'
        : 'Cliente General';

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50], // Match CartPage background
        border: isMobile
            ? null
            : Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
      ),
      child: Column(
        children: [
          // Header with Customer & Clear Cart
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title (only for tablet/desktop usually)
                if (!isMobile)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Carrito',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (cart.isNotEmpty)
                          TextButton(
                            onPressed: () =>
                                _confirmClearCart(context, posNotifier),
                            child: Text(
                              'Limpiar',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Customer Selection Tile
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          const CustomerSelectionDialogWidget(),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cliente: ',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Expanded(
                          child: Text(
                            customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cart Items List
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Carrito vacío',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return CartItemCard(
                        productName: item.productName ?? 'Desconocido',
                        variantName: item.variantDescription,
                        pricePerUnit: item.unitPrice,
                        total: item.total,
                        quantity: item.quantity,
                        onRemove: () {
                          posNotifier.removeFromCart(
                            item.productId,
                            variantId: item.variantId,
                          );
                        },
                        onDecrement: () async {
                          if (item.quantity > 1) {
                            final error = await posNotifier.updateQuantity(
                              item.productId,
                              item.quantity - 1,
                              variantId: item.variantId,
                            );
                            if (error != null && context.mounted) {
                              _showStockError(context, error);
                            }
                          } else {
                            posNotifier.removeFromCart(
                              item.productId,
                              variantId: item.variantId,
                            );
                          }
                        },
                        onIncrement: () async {
                          final error = await posNotifier.updateQuantity(
                            item.productId,
                            item.quantity + 1,
                            variantId: item.variantId,
                          );
                          if (error != null && context.mounted) {
                            _showStockError(context, error);
                          }
                        },
                      );
                    },
                  ),
          ),

          // Summary Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              children: [
                // Discount Mock (matching CartPage)
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Función de código de descuento pendiente',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        color: Colors.blue[700],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Agregar Código',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildTotalRow('Subtotal', subtotal),
                ...taxBreakdown.entries.map(
                  (entry) => _buildTotalRow(entry.key, entry.value),
                ),
                if (discount > 0)
                  _buildTotalRow('Descuento', -discount, isDiscount: true),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: cart.isEmpty
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => const PaymentDialog(),
                            );
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'COBRAR \$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
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
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDiscount ? Colors.green[600] : Colors.black87,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context, POSNotifier posNotifier) {
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
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('LIMPIAR'),
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
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
