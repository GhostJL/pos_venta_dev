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
    final theme = Theme.of(context);
    final provider = productFormProvider(product);

    // Obtenemos y ordenamos variantes
    final allVariants = ref.watch(provider.select((s) => s.variants));
    final variants = allVariants.toList()
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

    // Filtrado lógico coherente con la navegación previa
    final filteredVariants = variants.where((v) {
      if (filterType == null) return true;
      return v.type == filterType;
    }).toList();

    if (filteredVariants.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredVariants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final variant = filteredVariants[index];
        final originalIndex = allVariants.indexOf(variant);

        return _VariantCard(
          variant: variant,
          index: originalIndex,
          onEdit: onEditVariant,
          onDelete: (idx) => ref.read(provider.notifier).removeVariant(idx),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.layers_clear_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay variantes de ${filterType == VariantType.sales ? "venta" : "compra"}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza agregando una nueva presentación para este producto.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  final ProductVariant variant;
  final int index;
  final void Function(ProductVariant variant, int index) onEdit;
  final void Function(int index) onDelete;

  const _VariantCard({
    required this.variant,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSales = variant.type == VariantType.sales;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () => onEdit(variant, index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Identificador Visual (Círculo pequeño con inicial)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isSales ? theme.colorScheme.primary : Colors.teal)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isSales ? Icons.sell_outlined : Icons.inventory_2_outlined,
                    size: 20,
                    color: isSales
                        ? theme.colorScheme.primary
                        : Colors.teal.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.variantName.isEmpty
                          ? "Sin nombre"
                          : variant.variantName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildBadge(
                          theme,
                          isSales ? "Venta" : "Compra",
                          isSales ? theme.colorScheme.primary : Colors.teal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Stock: ${variant.quantity.toInt()} uds.",
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Precio / Costo Destacado
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${((isSales ? variant.priceCents : variant.costPriceCents) / 100).toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    isSales ? "Precio" : "Costo",
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Botón de eliminar (discreto)
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar variante?'),
        content: Text(
          'Esta acción eliminará la presentación "${variant.variantName}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              onDelete(index);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
