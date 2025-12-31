import 'dart:io';
import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = product.isActive;

    // Use a subtle surface color for the card background
    final cardColor = isActive
        ? theme.colorScheme.surfaceContainer
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    // Text colors with opacity for hierarchy
    final titleColor = isActive
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final subtitleColor = isActive
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive
              ? Colors.transparent
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading Icon / Image Placeholder
              _buildLeading(theme, isActive),
              const SizedBox(width: 16),

              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isActive)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Inactivo',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Code and Department
                    Row(
                      children: [
                        _buildTag(
                          theme,
                          '#${product.code}',
                          isActive: isActive,
                          isAccent: true,
                        ),
                        if (product.departmentName != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              product.departmentName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: subtitleColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price and Variants
                    Row(
                      children: [
                        Text(
                          '\$${(product.salePriceCents / 100).toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isActive
                                ? theme.colorScheme.primary
                                : titleColor,
                          ),
                        ),
                        if (product.variants != null &&
                            product.variants!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${product.variants!.length} var.',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Stock Indicator
              // Show only if there are variants (which imply stock logic is active)
              // or if we decide to show it for all products.
              // For now, let's show it if variants exist.
              if (product.variants != null && product.variants!.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildStockIndicator(theme, product),
              ],

              // Action Button (More)
              if (onMorePressed != null)
                IconButton(
                  onPressed: onMorePressed,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  style: IconButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockIndicator(ThemeData theme, Product product) {
    double totalStock = 0;
    bool isLowStock = false;

    if (product.variants != null) {
      for (var v in product.variants!) {
        totalStock += (v.stock ?? 0);
        if ((v.stock ?? 0) <= (v.stockMin ?? 5)) {
          isLowStock = true;
        }
      }
    }

    final isOutOfStock = totalStock <= 0;

    Color color;
    Color backgroundColor;
    IconData icon;

    if (isOutOfStock) {
      color = theme.colorScheme.error;
      backgroundColor = theme.colorScheme.errorContainer;
      icon = Icons.error_outline_rounded;
    } else if (isLowStock) {
      color = theme.colorScheme.tertiary;
      backgroundColor = theme.colorScheme.tertiaryContainer;
      icon = Icons.warning_amber_rounded;
    } else {
      color = theme.colorScheme.primary;
      backgroundColor = theme.colorScheme.primaryContainer;
      icon = Icons.inventory_2_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            _formatDouble(totalStock),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDouble(double value) {
    return value.toString().replaceAll(RegExp(r'\.0$'), '');
  }

  Widget _buildLeading(ThemeData theme, bool isActive) {
    if (product.photoUrl != null && product.photoUrl!.isNotEmpty) {
      if (product.photoUrl!.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            product.photoUrl!,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(theme, isActive),
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(product.photoUrl!),
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(theme, isActive),
          ),
        );
      }
    }
    return _buildPlaceholder(theme, isActive);
  }

  Widget _buildPlaceholder(ThemeData theme, bool isActive) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          product.name.isNotEmpty
              ? product.name.substring(0, 1).toUpperCase()
              : 'P',
          style: theme.textTheme.titleMedium?.copyWith(
            color: isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(
    ThemeData theme,
    String text, {
    bool isActive = true,
    bool isAccent = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: BoxDecoration(
        color: isAccent && isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isAccent && isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
