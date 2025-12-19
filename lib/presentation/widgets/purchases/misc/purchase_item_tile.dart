import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

class PurchaseItemTile extends ConsumerWidget {
  final Purchase purchase;
  final PurchaseItem item;

  const PurchaseItemTile({
    super.key,
    required this.item,
    required this.purchase,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productNotifierProvider);

    return productsAsync.when(
      data: (products) {
        final product = products
            .where((p) => p.id == item.productId)
            .firstOrNull;

        ProductVariant? variant;
        if (product != null && item.variantId != null) {
          variant = product.variants
              ?.where((v) => v.id == item.variantId)
              .firstOrNull;
        }

        return Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PurchaseItemHeader(item: item, variant: variant),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                _PurchaseItemDetails(item: item, variant: variant),
                const SizedBox(height: 16),
                _PurchaseItemFooter(item: item, purchase: purchase),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _PurchaseItemHeader extends StatelessWidget {
  final PurchaseItem item;
  final ProductVariant? variant;

  const _PurchaseItemHeader({required this.item, this.variant});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            item.productName ?? 'Producto #${item.productId}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (variant != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${variant!.quantity.toStringAsFixed(0)} un/caja',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PurchaseItemDetails extends StatelessWidget {
  final PurchaseItem item;
  final ProductVariant? variant;

  const _PurchaseItemDetails({required this.item, this.variant});

  @override
  Widget build(BuildContext context) {
    double displayQuantity = item.quantity;
    String displayUnit = item.unitOfMeasure;
    double displayCost = item.unitCost;

    if (variant != null) {
      displayQuantity = item.quantity / variant!.quantity;
      displayUnit = 'cajas/paq';
      if (displayQuantity > 0) {
        displayCost = (item.subtotalCents / 100.0) / displayQuantity;
      }
    }

    return Row(
      children: [
        Icon(
          Icons.shopping_cart_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text:
                      '${displayQuantity.toStringAsFixed(displayQuantity % 1 == 0 ? 0 : 2)} $displayUnit',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const TextSpan(text: ' × '),
                TextSpan(
                  text: '\$${displayCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const TextSpan(text: ' c/u'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PurchaseItemFooter extends StatelessWidget {
  final PurchaseItem item;
  final Purchase purchase;

  const _PurchaseItemFooter({required this.item, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final statusStyles = _getStatusStyles(item, purchase);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusStyles.bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusStyles.icon, size: 16, color: statusStyles.color),
              const SizedBox(width: 6),
              Text(
                statusStyles.text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: statusStyles.color,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '\$${(item.totalCents / 100).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  _StatusStyles _getStatusStyles(PurchaseItem item, Purchase purchase) {
    final isFullyReceived = item.quantityReceived >= item.quantity;
    final isPartiallyReceived =
        item.quantityReceived > 0 && item.quantityReceived < item.quantity;
    final isCancelled = purchase.status == PurchaseStatus.cancelled;

    if (isFullyReceived) {
      return _StatusStyles(
        color: AppTheme.transactionSuccess,
        bgColor: AppTheme.transactionSuccess.withValues(alpha: 0.2),
        icon: Icons.check_circle_rounded,
        text: 'Completado',
      );
    } else if (isPartiallyReceived) {
      return _StatusStyles(
        color: AppTheme.transactionPending,
        bgColor: AppTheme.transactionPending.withValues(alpha: 0.2),
        icon: Icons.schedule_rounded,
        text: '${item.quantityReceived} de ${item.quantity}',
      );
    } else if (isCancelled) {
      return _StatusStyles(
        color: AppTheme.transactionFailed,
        bgColor: AppTheme.transactionFailed.withValues(alpha: 0.2),
        icon: Icons.cancel_rounded,
        text: 'Cancelado',
      );
    } else {
      return _StatusStyles(
        color: AppTheme.alertInfo,
        bgColor: AppTheme.alertInfo.withValues(alpha: 0.2),
        icon: Icons.pending_rounded,
        text: 'Pendiente',
      );
    }
  }
}

class _StatusStyles {
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String text;

  _StatusStyles({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.text,
  });
}
