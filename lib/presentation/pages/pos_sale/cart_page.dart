import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/pages/pos_sale/widgets/cart_item_card.dart';
import 'package:posventa/presentation/widgets/pos/consumer_selection_dialog_widget.dart';
import 'package:posventa/presentation/widgets/pos/payment/payment_dialog.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50], // surfaceContainerLow
      appBar: AppBar(
        title: Text(
          'Carrito',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(pOSProvider.notifier).clearCart();
            },
            child: Text(
              'Limpiar',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const CustomerSelectionSection(),
          // const Divider(height: 1), // Removed divider for cleaner look
          const Expanded(child: CartListSection()),
          const CartSummarySection(),
        ],
      ),
    );
  }
}

class CustomerSelectionSection extends ConsumerWidget {
  const CustomerSelectionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCustomer = ref.watch(
      pOSProvider.select((state) => state.selectedCustomer),
    );

    final displayText = selectedCustomer != null
        ? '${selectedCustomer.firstName} ${selectedCustomer.lastName}'
        : 'Cliente General';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const CustomerSelectionDialogWidget(),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Cliente: ',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
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
    );
  }
}

class CartListSection extends ConsumerWidget {
  const CartListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(pOSProvider.select((s) => s.cart));

    if (cart.isEmpty) {
      return Center(
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
              'El carrito está vacío',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = cart[index];
        return CartItemWrapper(item: item);
      },
    );
  }
}

class CartItemWrapper extends ConsumerWidget {
  final SaleItem item;
  const CartItemWrapper({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posNotifier = ref.read(pOSProvider.notifier);

    return CartItemCard(
      productName: item.productName ?? 'Desconocido',
      variantName: item.variantDescription, // Mapped correctly
      pricePerUnit: item.unitPrice,
      total: item.total,
      quantity: item.quantity,
      onRemove: () {
        posNotifier.removeFromCart(item.productId, variantId: item.variantId);
      },
      onDecrement: () {
        if (item.quantity > 1) {
          posNotifier.updateQuantity(
            item.productId,
            item.quantity - 1,
            variantId: item.variantId,
          );
        } else {
          posNotifier.removeFromCart(item.productId, variantId: item.variantId);
        }
      },
      onIncrement: () {
        posNotifier.updateQuantity(
          item.productId,
          item.quantity + 1,
          variantId: item.variantId,
        );
      },
    );
  }
}

class CartSummarySection extends ConsumerWidget {
  const CartSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(pOSProvider.select((s) => s.subtotal));
    final total = ref.watch(pOSProvider.select((s) => s.total));
    final discount = ref.watch(pOSProvider.select((s) => s.discount));
    final cartIsEmpty = ref.watch(pOSProvider.select((s) => s.cart.isEmpty));
    final taxBreakdown = ref.watch(posTaxBreakdownProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add Discount Code
          InkWell(
            onTap: () {
              // TODO: Implement discount code dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de código de descuento pendiente'),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.local_offer, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Agregar Código de Descuento',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Summary Rows
          _buildSummaryRow(context, 'Subtotal', subtotal),

          // Dynamic Tax Breakdown
          ...taxBreakdown.entries.map(
            (entry) => _buildSummaryRow(context, entry.key, entry.value),
          ),

          if (discount > 0)
            _buildSummaryRow(context, 'Descuento', -discount, isDiscount: true),

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

          const SizedBox(height: 24),

          // Charge Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: cartIsEmpty
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
                    'Cobrar \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDiscount ? Colors.green[600] : Colors.black87,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
