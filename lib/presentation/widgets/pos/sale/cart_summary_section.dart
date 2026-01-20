import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

class CartSummarySection extends ConsumerWidget {
  const CartSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch relevant state
    final cart = ref.watch(pOSProvider.select((s) => s.cart));
    final subtotal = ref.watch(pOSProvider.select((s) => s.subtotal));
    final total = ref.watch(pOSProvider.select((s) => s.total));
    final discount = ref.watch(pOSProvider.select((s) => s.discount));
    final taxBreakdown = ref.watch(posTaxBreakdownProvider);

    // Global Settings
    final settingsAsync = ref.watch(settingsProvider);
    final useTax = settingsAsync.value?.useTax ?? true;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Subtotal (before discounts and taxes)
            _buildTotalRow(context, 'Subtotal', subtotal),

            // Discount if applicable
            if (discount > 0) ...[
              const SizedBox(height: 4),
              _buildTotalRow(context, 'Descuento', -discount, isDiscount: true),
            ],

            // Subtotal Neto (after discount, before tax) - only show if there's discount or tax
            if (discount > 0 || (useTax && taxBreakdown.isNotEmpty)) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 1),
              ),
              _buildTotalRow(
                context,
                'Subtotal Neto',
                subtotal - discount,
                isSubtotalNeto: true,
              ),
            ],

            // Taxes if applicable
            if (useTax && taxBreakdown.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...taxBreakdown.entries.map(
                (entry) => _buildTotalRow(
                  context,
                  entry.key,
                  entry.value,
                  isTax: true,
                ),
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 2),
            ),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a Pagar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    height: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: cart.isEmpty
                    ? null
                    : () {
                        context.push('/pos/payment');
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cobrar \$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
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

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount, {
    bool isDiscount = false,
    bool isSubtotalNeto = false,
    bool isTax = false,
  }) {
    // Determine styling based on row type
    Color textColor;
    FontWeight fontWeight;
    String prefix = '';

    if (isDiscount) {
      textColor = Colors.green[600]!;
      fontWeight = FontWeight.w600;
      // Amount is already negative, no prefix needed
    } else if (isTax) {
      textColor = Theme.of(context).colorScheme.onSurface;
      fontWeight = FontWeight.w500;
      prefix = '+';
    } else if (isSubtotalNeto) {
      textColor = Theme.of(context).colorScheme.onSurface;
      fontWeight = FontWeight.w600;
    } else {
      textColor = Theme.of(context).colorScheme.onSurface;
      fontWeight = FontWeight.w500;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: isSubtotalNeto
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$prefix\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
