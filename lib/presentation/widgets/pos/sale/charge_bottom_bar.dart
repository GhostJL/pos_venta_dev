import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/cart_item_widget.dart';
import 'package:posventa/presentation/widgets/pos/customer_selection_widget.dart';
import 'package:posventa/presentation/widgets/pos/payment/payment_dialog.dart';
import 'package:posventa/core/theme/theme.dart';

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
      backgroundColor: Colors.transparent,
      builder: (context) => const _MobileCartSheet(),
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

class _MobileCartSheet extends StatelessWidget {
  const _MobileCartSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        children: [
          _buildDragHandle(colorScheme),
          const _CartHeader(),
          const Divider(height: 1),
          const Expanded(child: _CartList()),
          const _CartSummary(),
        ],
      ),
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Resumen de Venta',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const CustomerSelectionWidget(),
        ],
      ),
    );
  }
}

class _CartList extends ConsumerWidget {
  const _CartList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild if the list of items changes (length or content)
    // We select the cart to ensure granular updates
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
        // We can pass the item directly. If the item inside the list changes,
        // this builder will be called.
        // For even MORE granularity, one could make a granular Item widget
        // that takes an ID and watches that specific item, but passing the
        // item from the list here is usually standard and performant enough
        // provided the list itself isn't rebuilt unnecessarily.
        final item = cart[index];
        return _CartItemWrapper(item: item);
      },
    );
  }
}

class _CartItemWrapper extends ConsumerWidget {
  final SaleItem item;
  const _CartItemWrapper({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We read notifier here to avoid watching it
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

class _CartSummary extends ConsumerWidget {
  const _CartSummary();

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
                      Navigator.pop(context); // Close sheet
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
