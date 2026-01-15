import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/pages/pos_sale/widgets/cart_item_card.dart';
import 'package:posventa/presentation/widgets/pos/sale/cart_quantity_dialog.dart';
import 'package:posventa/presentation/widgets/pos/sale/cart_header_section.dart';
import 'package:posventa/presentation/widgets/pos/sale/cart_summary_section.dart';

class CartSection extends ConsumerWidget {
  final bool isMobile;

  const CartSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(pOSProvider.select((s) => s.cart));
    final posNotifier = ref.read(pOSProvider.notifier);

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // Header
          CartHeaderSection(
            isMobile: isMobile,
            onClearCart: () => _confirmClearCart(context, posNotifier),
          ),

          // Cart Items List
          Expanded(
            child: cart.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Better for desktop
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
          const CartSummarySection(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'El carrito está vacío',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escanea un producto o búscalo\npara comenzar la venta',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
