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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Item Count & Summary Link
            if (itemCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: onViewCart,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${itemCount.toStringAsFixed(0)} artículos',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tax / Info Placeholders (simplified to not float awkwardly)
                    Row(
                      children: taxBreakdown.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Main Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: onCharge,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cobrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
