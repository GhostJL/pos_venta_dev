import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';

class ConnectedChargeBottomBar extends ConsumerWidget {
  const ConnectedChargeBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select specific values to avoid unnecessary rebuilds
    final total = ref.watch(pOSProvider.select((s) => s.total));
    final cartItems = ref.watch(pOSProvider.select((s) => s.cart));
    final cartIsEmpty = cartItems.isEmpty;
    final taxBreakdown = ref.watch(posTaxBreakdownProvider);

    return ChargeBottomBar(
      cartItems: cartItems,
      total: total,
      taxBreakdown: taxBreakdown,
      onCharge: cartIsEmpty
          ? null
          : () {
              context.push('/pos/payment');
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
  final Map<String, double> taxBreakdown;
  final VoidCallback? onCharge;
  final VoidCallback? onViewCart;

  const ChargeBottomBar({
    super.key,
    required this.cartItems,
    required this.total,
    required this.taxBreakdown,
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
                  ...taxBreakdown.entries.map(
                    (entry) => _buildTotalRow(
                      context,
                      entry.key.toString(),
                      entry.value,
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
                    'Total: \$${total.toStringAsFixed(2)}',
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

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount, {
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDiscount
                  ? Colors.green[600]
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
