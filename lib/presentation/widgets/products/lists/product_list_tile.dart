import 'dart:io';
import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';
import 'package:posventa/presentation/widgets/common/right_click_menu_wrapper.dart';

class ProductListTile extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isActive = product.isActive;
    final settings = ref.watch(settingsProvider).value;
    final useInventory = settings?.useInventory ?? true;

    // Row Layout for Desktop
    return RightClickMenuWrapper(
      onRightClick: onMorePressed,
      child: InkWell(
        onTap: onTap,
        hoverColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              // 1. Photo
              SizedBox(
                width: 48,
                height: 48,
                child: _buildLeading(theme, isActive),
              ),
              const SizedBox(width: 16),

              // 2. Code & Name
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? null
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${product.code}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        if (!isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'INACTIVO',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Department / Brand
              if (MediaQuery.of(context).size.width > 1100)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (product.departmentName != null)
                        Text(
                          product.departmentName!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

              // 4. Price
              Expanded(
                flex: 2,
                child: Text(
                  '\$${(product.salePriceCents / 100).toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              // 5. Stock (Removed)
              if (useInventory) const Expanded(flex: 2, child: SizedBox()),

              // 6. Actions
              SizedBox(
                width: 48,
                child: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: onMorePressed,
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(ThemeData theme, bool isActive) {
    if (product.photoUrl != null && product.photoUrl!.isNotEmpty) {
      final imageProvider = product.photoUrl!.startsWith('http')
          ? NetworkImage(product.photoUrl!)
          : FileImage(File(product.photoUrl!)) as ImageProvider;

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: ResizeImage(imageProvider, width: 100),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(theme, isActive),
        ),
      );
    }
    return _buildPlaceholder(theme, isActive);
  }

  Widget _buildPlaceholder(ThemeData theme, bool isActive) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          product.name.isNotEmpty ? product.name[0].toUpperCase() : 'P',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /* _buildStockIndicator Removed */
}
