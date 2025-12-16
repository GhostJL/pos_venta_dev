import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';

class ProductVariantsList extends ConsumerWidget {
  final Product? product;
  final void Function(VariantType type) onAddVariant;
  final void Function(ProductVariant variant, int index) onEditVariant;
  final VariantType? filterType;

  const ProductVariantsList({
    super.key,
    required this.product,
    required this.onAddVariant,
    required this.onEditVariant,
    this.filterType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productFormProvider(product);
    // Sort variants to ensure stable order
    final variants = ref.watch(provider.select((s) => s.variants)).toList()
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

    final salesVariants = variants
        .where(
          (v) =>
              (filterType == null || filterType == VariantType.sales) &&
              (v.type == VariantType.sales ||
                  (v.type == VariantType.purchase && v.isForSale)),
        )
        .toList();
    final purchaseVariants = variants
        .where(
          (v) =>
              (filterType == null || filterType == VariantType.purchase) &&
              v.type == VariantType.purchase,
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (variants.isEmpty)
              _buildEmptyState(context)
            else ...[
              if (salesVariants.isNotEmpty) ...[
                _buildListHeader(context, 'Variantes de Venta', Icons.sell),
                const SizedBox(height: 8),
                _buildVariantsList(
                  context,
                  ref,
                  salesVariants,
                  isCompact,
                  isSalesList: true,
                ),
                const SizedBox(height: 24),
              ],
              if (purchaseVariants.isNotEmpty) ...[
                _buildListHeader(
                  context,
                  'Variantes de Compra',
                  Icons.inventory,
                ),
                const SizedBox(height: 8),
                _buildVariantsList(
                  context,
                  ref,
                  purchaseVariants,
                  isCompact,
                  isSalesList: false,
                ),
                const SizedBox(height: 24),
              ],
            ],
            SizedBox(height: isCompact ? 16 : 0),
            _buildAddButton(context, isCompact),
          ],
        );
      },
    );
  }

  Widget _buildListHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildVariantsList(
    BuildContext context,
    WidgetRef ref,
    List<ProductVariant> variants,
    bool isCompact, {
    bool isSalesList = false,
  }) {
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
            itemBuilder: (context, index) {
              final originalIndex = ref
                  .read(productFormProvider(product))
                  .variants
                  .indexOf(variants[index]);

              return _VariantItemRow(
                variant: variants[index],
                index: originalIndex,
                onEdit: onEditVariant,
                onDelete: (idx) => ref
                    .read(productFormProvider(product).notifier)
                    .removeVariant(idx),
                isCompact: isCompact,
                isSalesList: isSalesList,
              );
            },
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
      onPressed: () {
        if (filterType != null) {
          onAddVariant(filterType!);
        } else {
          _showVariantTypeSelection(context);
        }
      },
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(isCompact ? 'Agregar Variante' : 'Agregar Nueva Variante'),
    );
  }

  void _showVariantTypeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sell_outlined),
              title: const Text('Variante de Venta'),
              subtitle: const Text(
                'Para vender el producto en diferentes presentaciones',
              ),
              onTap: () {
                Navigator.pop(context);
                onAddVariant(VariantType.sales);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Variante de Compra'),
              subtitle: const Text(
                'Para comprar el producto en cajas, bultos, etc.',
              ),
              onTap: () {
                Navigator.pop(context);
                onAddVariant(VariantType.purchase);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
  final bool isSalesList;

  const _VariantItemRow({
    required this.variant,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.isCompact,
    this.isSalesList = false,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.variantName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (variant.type == VariantType.purchase)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isSalesList ? 'Compra + Venta' : 'Compra',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _buildActionButtons(context),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricCompact(
                context,
                icon: !isSalesList
                    ? Icons.monetization_on_outlined
                    : Icons.attach_money_rounded,
                label: !isSalesList
                    ? 'Costo: \$${_formatPrice(variant.costPriceCents)}'
                    : 'Precio: \$${_formatPrice(variant.priceCents)}',
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  variant.variantName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (variant.type == VariantType.purchase)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isSalesList
                            ? 'Compra + Venta'
                            : 'Compra (Enlace: ${variant.linkedVariantId ?? "Base"})',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildMetricCompact(
            context,
            icon: !isSalesList
                ? Icons.monetization_on_outlined
                : Icons.attach_money_rounded,
            label: !isSalesList
                ? 'Costo: \$${_formatPrice(variant.costPriceCents)}'
                : '\$${_formatPrice(variant.priceCents)}',
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
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
