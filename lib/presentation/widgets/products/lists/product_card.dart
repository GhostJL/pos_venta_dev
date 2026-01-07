import 'dart:io';
import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';

class ProductCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Global Settings
    final settingsAsync = ref.watch(settingsProvider);
    final useInventory = settingsAsync.value?.useInventory ?? true;

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
            crossAxisAlignment: CrossAxisAlignment.start, // Align top for image
            children: [
              // Leading Icon / Image Placeholder
              _buildLeading(theme, isActive),
              const SizedBox(width: 12),

              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ROW 1: Title + Menu Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                  height: 1.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (!isActive)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
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
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onErrorContainer,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (onMorePressed != null)
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              onPressed: onMorePressed,
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              style: IconButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // ROW 2: Metadata (Code, Dept)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildTag(
                          theme,
                          '#${product.code}',
                          isActive: isActive,
                          isAccent: true,
                        ),
                        if (product.departmentName != null)
                          Text(
                            product.departmentName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: subtitleColor,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ROW 3: Price + Stats (Bottom Row)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price & Variants Group
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  product.variants!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '${product.variants!.length} variantes',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: subtitleColor,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Stock Indicator (Right aligned)
                        if (useInventory &&
                            product.variants != null &&
                            product.variants!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(child: _buildStockIndicator(theme, product)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockIndicator(ThemeData theme, Product product) {
    final totalStock = product.totalStock;
    final maxStock = product.maxStockLimit;
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.isOutOfStock;

    // Progress calculation (clamped between 0 and 1)
    final progress = (totalStock / maxStock).clamp(0.0, 1.0);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
                '${_formatDouble(totalStock)} Unid.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: color,
            minHeight: 3,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
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
