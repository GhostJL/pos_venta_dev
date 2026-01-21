import 'package:flutter/material.dart';

/// A chip widget that displays a payment method with an icon
class SalePaymentMethodChip extends StatelessWidget {
  final String paymentMethod;
  final double amount;
  final bool isCompact;

  const SalePaymentMethodChip({
    super.key,
    required this.paymentMethod,
    required this.amount,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = getIconForMethod(paymentMethod);
    final color = getColorForMethod(paymentMethod, theme);

    if (isCompact) {
      return Chip(
        avatar: Icon(icon, size: 16, color: color),
        label: Text(
          paymentMethod,
          style: TextStyle(fontSize: 11, color: color),
        ),
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                paymentMethod,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData getIconForMethod(String method) {
    final methodLower = method.toLowerCase();
    if (methodLower.contains('efectivo')) {
      return Icons.payments_outlined;
    } else if (methodLower.contains('tarjeta') ||
        methodLower.contains('card')) {
      return Icons.credit_card_outlined;
    } else if (methodLower.contains('transferencia') ||
        methodLower.contains('transfer')) {
      return Icons.account_balance_outlined;
    } else if (methodLower.contains('crédito') ||
        methodLower.contains('credit')) {
      return Icons.receipt_long_outlined;
    } else {
      return Icons.payment_outlined;
    }
  }

  static Color getColorForMethod(String method, [ThemeData? theme]) {
    final methodLower = method.toLowerCase();
    if (methodLower.contains('efectivo')) {
      return Colors.green;
    } else if (methodLower.contains('tarjeta') ||
        methodLower.contains('card')) {
      return Colors.blue;
    } else if (methodLower.contains('transferencia') ||
        methodLower.contains('transfer')) {
      return Colors.purple;
    } else if (methodLower.contains('crédito') ||
        methodLower.contains('credit')) {
      return Colors.orange;
    } else {
      return theme?.colorScheme.primary ?? Colors.grey;
    }
  }
}
