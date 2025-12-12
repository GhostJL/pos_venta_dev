import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';

import 'package:posventa/domain/entities/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onMorePressed;
  final VoidCallback? onTap;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onMorePressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildProductIcon(context),
              const SizedBox(width: 12),
              Expanded(child: _buildProductInfo(context)),
              _buildTrailing(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                '\$${(product.salePriceCents / 100).toStringAsFixed(2)}',
                key: ValueKey(product.salePriceCents),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: (product.stock ?? 0) < 5
                    ? AppTheme.metricExpenses.withValues(alpha: 0.1)
                    : (product.stock ?? 0) >= 5 && (product.stock ?? 0) < 20
                    ? AppTheme.alertWarning.withValues(alpha: 0.1)
                    : AppTheme.actionConfirm.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${product.stock ?? ''} ${(product.stock ?? 0) < 5 ? 'Sin stock' : ((product.stock ?? 0) >= 5 && (product.stock ?? 0) < 20 ? 'Uds. (bajas)' : 'Uds.')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: (product.stock ?? 0) < 5
                      ? AppTheme.metricExpenses
                      : ((product.stock ?? 0) >= 5 && (product.stock ?? 0) < 20)
                      ? AppTheme.alertWarning
                      : AppTheme.actionConfirm,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'SKU: ${product.code}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (product.departmentName != null &&
                product.departmentName!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                width: 1.5,
                height: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                product.departmentName!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          splashRadius: 20,
          tooltip: 'Más opciones',
          onPressed: onMorePressed,
        ),
      ],
    );
  }
}
