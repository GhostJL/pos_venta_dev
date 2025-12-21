import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/pages/pos_sale/widgets/cart_item_card.dart';
import 'package:posventa/presentation/widgets/pos/consumer_selection_dialog_widget.dart';
import 'package:posventa/presentation/widgets/pos/sale/cart_quantity_dialog.dart';
import 'package:go_router/go_router.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(
          'Carrito',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(pOSProvider.notifier).clearCart();
            },
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: colorScheme.error,
            ),
            label: Text(
              'Limpiar',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
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
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const CustomerSelectionDialogWidget(),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cliente',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      displayText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'El carrito está vacío',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => CartQuantityDialog(
            productId: item.productId,
            variantId: item.variantId,
            productName: item.productName ?? '',
            variantName: item.variantDescription,
            currentQuantity: item.quantity,
          ),
        );
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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
                      context.push('/pos/payment');
                    },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
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
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDiscount
                  ? Colors.green[600]
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
