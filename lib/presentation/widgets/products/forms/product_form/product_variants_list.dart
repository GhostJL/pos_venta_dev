import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';

/// Widget for displaying and managing product variants list
class ProductVariantsList extends ConsumerWidget {
  final Product? product;
  final VoidCallback onAddVariant;
  final void Function(ProductVariant variant, int index) onEditVariant;

  const ProductVariantsList({
    super.key,
    required this.product,
    required this.onAddVariant,
    required this.onEditVariant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productFormProvider(product);
    final variants = ref.watch(provider.select((s) => s.variants));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (variants.isEmpty)
              _buildEmptyState(context)
            else
              _buildVariantsList(context, ref, variants, isCompact),

            SizedBox(height: isCompact ? 16 : 24),

            _buildAddButton(context, isCompact),
          ],
        );
      },
    );
  }

  Widget _buildVariantsList(
    BuildContext context,
    WidgetRef ref,
    List<ProductVariant> variants,
    bool isCompact,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: variants.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) => _VariantItemRow(
              variant: variants[index],
              index: index,
              onEdit: onEditVariant,
              onDelete: (idx) => ref
                  .read(productFormProvider(product).notifier)
                  .removeVariant(idx),
              isCompact: isCompact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sin variantes definidas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El producto se venderá con su configuración principal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Agrega variantes como talla o color para personalizar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, bool isCompact) {
    return OutlinedButton.icon(
      onPressed: onAddVariant,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(isCompact ? 'Agregar Variante' : 'Agregar Nueva Variante'),
    );
  }
}

// --- Fila de Variante con Mejores Colores ---
class _VariantItemRow extends StatelessWidget {
  final ProductVariant variant;
  final int index;
  final void Function(ProductVariant variant, int index) onEdit;
  final void Function(int index) onDelete;
  final bool isCompact;

  const _VariantItemRow({
    required this.variant,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.isCompact,
  });

  String _formatPrice(int cents) {
    return (cents / 100).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return isCompact
        ? _buildCompactLayout(context)
        : _buildExpandedLayout(context);
  }

  // Layout para pantallas pequeñas (móvil)
  Widget _buildCompactLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  variant.variantName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _buildActionButtons(context),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Precio con color primario
              _buildMetricCompact(
                context,
                icon: Icons.attach_money_rounded,
                label: _formatPrice(variant.priceCents),
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              // Stock con color terciario (alternativa elegante al secundario)
              _buildMetricCompact(
                context,
                icon: Icons.inventory_2_outlined,
                label: '${variant.quantity} uds.',
                color: colorScheme.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCompact(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  // Layout para pantallas grandes (tablet/desktop)
  Widget _buildExpandedLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              variant.variantName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildMetricCompact(
            context,
            icon: Icons.attach_money_rounded,
            label: _formatPrice(variant.priceCents),
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          // Stock con color terciario (alternativa elegante al secundario)
          _buildMetricCompact(
            context,
            icon: Icons.inventory_2_outlined,
            label: '${variant.quantity} uds.',
            color: colorScheme.onSurface,
          ),
          const SizedBox(width: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: () => onEdit(variant, index),
          tooltip: 'Editar',
          visualDensity: VisualDensity.compact,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 20),
          onPressed: () => onDelete(index),
          tooltip: 'Eliminar',
          visualDensity: VisualDensity.compact,
          color: colorScheme.error,
        ),
      ],
    );
  }
}
