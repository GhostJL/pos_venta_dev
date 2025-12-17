import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/widgets/pos/payment/payment_dialog.dart';

class ConnectedChargeBottomBar extends ConsumerWidget {
  const ConnectedChargeBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select specific values to avoid unnecessary rebuilds
    final total = ref.watch(pOSProvider.select((s) => s.total));
    final cartItems = ref.watch(pOSProvider.select((s) => s.cart));
    final cartIsEmpty = cartItems.isEmpty;

    return ChargeBottomBar(
      cartItems: cartItems,
      total: total,
      onCharge: cartIsEmpty
          ? null
          : () {
              // Just open payment dialog directly as per original flow
              showDialog(
                context: context,
                builder: (context) => const PaymentDialog(),
              );
            },
      onViewCart: () {
        context.push('/cart');
      },
    );
  }
}

class ChargeBottomBar extends StatelessWidget {
  final List<SaleItem> cartItems;
  final double total;
  final VoidCallback? onCharge;
  final VoidCallback? onViewCart;

  const ChargeBottomBar({
    super.key,
    required this.cartItems,
    required this.total,
    this.onCharge,
    this.onViewCart,
  });

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
            onTap: onViewCart,
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
                    Icons.arrow_forward_ios,
                    size: 12,
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
