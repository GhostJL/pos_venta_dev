import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/cart_item_widget.dart';
import 'package:posventa/presentation/widgets/pos/customer_selection_widget.dart';
import 'package:posventa/presentation/widgets/pos/payment/payment_dialog.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Venta'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const CustomerSelectionSection(),
          const Divider(height: 1),
          const Expanded(child: CartListSection()),
          const CartSummarySection(),
        ],
      ),
    );
  }
}

class CustomerSelectionSection extends StatelessWidget {
  const CustomerSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomerSelectionWidget(),
    );
  }
}

class CartListSection extends ConsumerWidget {
  const CartListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(pOSProvider.select((s) => s.cart));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'El carrito está vacío',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
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
    // Read notifier to avoid unnecessary rebuilds
    final posNotifier = ref.read(pOSProvider.notifier);

    return GestureDetector(
      onLongPress: () => _showQuantityDialog(context, item, posNotifier),
      child: CartItemWidget(
        productName: item.productName,
        variantDescription: item.variantDescription,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        total: item.total,
        onPressedRemove: () {
          posNotifier.removeFromCart(item.productId, variantId: item.variantId);
        },
        onTapLessProduct: () {
          if (item.quantity > 1) {
            posNotifier.updateQuantity(
              item.productId,
              item.quantity - 1,
              variantId: item.variantId,
            );
          } else {
            posNotifier.removeFromCart(
              item.productId,
              variantId: item.variantId,
            );
          }
        },
        onTapMoreProduct: () {
          posNotifier.updateQuantity(
            item.productId,
            item.quantity + 1,
            variantId: item.variantId,
          );
        },
      ),
    );
  }

  void _showQuantityDialog(
    BuildContext context,
    SaleItem item,
    POSNotifier posNotifier,
  ) {
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
                  posNotifier.updateQuantity(
                    item.productId,
                    newQuantity,
                    variantId: item.variantId,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}

class CartSummarySection extends ConsumerWidget {
  const CartSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch specific values to rebuild ONLY when totals change
    final subtotal = ref.watch(pOSProvider.select((s) => s.subtotal));
    final total = ref.watch(pOSProvider.select((s) => s.total));
    final discount = ref.watch(pOSProvider.select((s) => s.discount));
    final cartIsEmpty = ref.watch(pOSProvider.select((s) => s.cart.isEmpty));
    final taxBreakdown = ref.watch(posTaxBreakdownProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(context, 'Subtotal', subtotal),

          // Dynamic Tax Breakdown
          ...taxBreakdown.entries.map(
            (entry) => _buildSummaryRow(context, entry.key, entry.value),
          ),

          if (discount > 0)
            _buildSummaryRow(context, 'Descuento', -discount, isDiscount: true),

          const Divider(height: 24),
          _buildSummaryRow(context, 'TOTAL', total, isBold: true, fontSize: 20),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: cartIsEmpty
                  ? null
                  : () {
                      // Navigator.pop(context); // Not needed in a full page unless we want to go back?
                      // Wait, we probably want to show PaymentDialog ON TOP of this page
                      showDialog(
                        context: context,
                        builder: (context) => const PaymentDialog(),
                      );
                    },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CONTINUAR AL PAGO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    bool isBold = false,
    double fontSize = 14,
    bool isDiscount = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
              fontSize: fontSize,
              color: isDiscount
                  ? AppTheme.transactionSuccess
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
