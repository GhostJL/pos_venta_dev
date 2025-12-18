import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isActive = product.isActive;

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.surfaceContainer
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline, width: 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 1. Visual
              _buildLeading(theme, isActive),
              const SizedBox(width: 12),

              // 2. Información
              Expanded(
                child: isTablet
                    ? _buildTabletLayout(theme, isActive)
                    : _buildMobileLayout(theme, isActive),
              ),

              // 3. Acción
              IconButton(
                onPressed: onMorePressed,
                icon: const Icon(Icons.more_horiz_rounded),
                color: theme.colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LAYOUTS ADAPTATIVOS ---

  // Layout para Tablet: Todo en una línea
  Widget _buildTabletLayout(ThemeData theme, bool isActive) {
    return Row(
      children: [
        Expanded(child: _buildMainInfo(theme, isActive)),
        const SizedBox(width: 16),
        _buildPriceInfo(theme, isActive),
      ],
    );
  }

  // Layout para Móvil: Información arriba, precio abajo del nombre
  Widget _buildMobileLayout(ThemeData theme, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMainInfo(theme, isActive),
        const SizedBox(height: 4),
        _buildPriceInfo(theme, isActive, isHorizontal: true),
      ],
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildLeading(ThemeData theme, bool isActive) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          product.name.isNotEmpty
              ? product.name.substring(0, 1).toUpperCase()
              : 'P',
          style: TextStyle(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo(ThemeData theme, bool isActive) {
    final textColor = isActive
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        _buildSubInfo(theme, isActive),
      ],
    );
  }

  Widget _buildSubInfo(ThemeData theme, bool isActive) {
    final primaryColor = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.primary.withValues(alpha: 0.5);
    final secondaryColor = isActive
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "#${product.code}",
          style: theme.textTheme.labelSmall?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (product.departmentName != null) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              "• ${product.departmentName!}",
              style: theme.textTheme.labelSmall?.copyWith(
                color: secondaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceInfo(
    ThemeData theme,
    bool isActive, {
    bool isHorizontal = false,
  }) {
    final textColor = isActive
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);

    final priceWidget = Text(
      '\$${(product.salePriceCents / 100).toStringAsFixed(2)}',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: textColor,
      ),
    );

    final variantsWidget = product.variants != null
        ? Text(
            "${product.variants!.length} var.",
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.7),
            ),
          )
        : const SizedBox.shrink();

    if (isHorizontal) {
      return Row(
        children: [priceWidget, const SizedBox(width: 8), variantsWidget],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [priceWidget, variantsWidget],
    );
  }
}
