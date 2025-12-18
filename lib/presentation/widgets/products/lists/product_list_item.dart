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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 1. Visual (Fijo a la izquierda)
              _buildLeading(theme),
              const SizedBox(width: 12),

              // 2. Información y Precio (Flexible)
              Expanded(
                child: isTablet
                    ? _buildTabletLayout(theme)
                    : _buildMobileLayout(theme),
              ),

              // 3. Acción (Fijo a la derecha)
              IconButton(
                onPressed: onMorePressed,
                icon: const Icon(Icons.chevron_right_rounded),
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
  Widget _buildTabletLayout(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildMainInfo(theme)),
        const SizedBox(width: 16),
        _buildPriceInfo(theme),
      ],
    );
  }

  // Layout para Móvil: Información arriba, precio abajo del nombre
  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMainInfo(theme),
        const SizedBox(height: 4),
        _buildPriceInfo(theme, isHorizontal: true),
      ],
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildLeading(ThemeData theme) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          product.name.isNotEmpty
              ? product.name.substring(0, 1).toUpperCase()
              : 'P',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        _buildSubInfo(theme),
      ],
    );
  }

  Widget _buildSubInfo(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "#${product.code}",
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (product.departmentName != null) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              "• ${product.departmentName!}",
              style: theme.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceInfo(ThemeData theme, {bool isHorizontal = false}) {
    final priceWidget = Text(
      '\$${(product.salePriceCents / 100).toStringAsFixed(2)}',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.onSurface,
      ),
    );

    final variantsWidget = product.variants != null
        ? Text(
            "${product.variants!.length} var.",
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
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
