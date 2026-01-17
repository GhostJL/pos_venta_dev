import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';

class ProductVariantsList extends ConsumerWidget {
  final Product? product;
  final void Function(VariantType type)? onAddVariant;
  final void Function(ProductVariant variant, int index) onEditVariant;
  final void Function(int index)? onDeleteVariant;
  final VariantType? filterType;

  const ProductVariantsList({
    super.key,
    required this.product,
    this.onAddVariant,
    required this.onEditVariant,
    this.onDeleteVariant,
    this.filterType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = productFormProvider(product);

    // Obtenemos y ordenamos variantes
    final allVariants = ref.watch(provider.select((s) => s.variants));
    final variants = allVariants.toList();
    // ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0)); // Don't sort by ID as new variants have null ID

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
          onDelete: (idx) {
            if (onDeleteVariant != null) {
              onDeleteVariant!(idx);
            } else {
              ref.read(provider.notifier).removeVariant(idx);
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isFilteringSales = filterType == VariantType.sales;
    final typeText = filterType == null
        ? "presentaciones"
        : (isFilteringSales ? "variantes de venta" : "variantes de compra");

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.layers_clear_outlined,
            size: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay $typeText',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agrega variantes para tener diferentes precios o presentaciones.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSales = variant.type == VariantType.sales;

    // Obtener el nombre de la unidad
    final unitsAsync = ref.watch(unitListProvider);
    final unitName = unitsAsync.maybeWhen(
      data: (units) => units
          .where((u) => u.id == variant.unitId)
          .firstOrNull
          ?.name
          .toLowerCase(),
      orElse: () => null,
    );

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () => onEdit(variant, index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Identificador Visual (Círculo pequeño con inicial o imagen)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      (isSales
                              ? theme.colorScheme.primary
                              : theme.colorScheme.tertiary)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  image:
                      (variant.photoUrl != null && variant.photoUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: variant.photoUrl!.startsWith('http')
                              ? NetworkImage(variant.photoUrl!)
                              : FileImage(File(variant.photoUrl!))
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (variant.photoUrl == null || variant.photoUrl!.isEmpty)
                    ? Center(
                        child: Icon(
                          isSales
                              ? Icons.sell_outlined
                              : Icons.inventory_2_outlined,
                          size: 18,
                          color: isSales
                              ? theme.colorScheme.primary
                              : theme.colorScheme.tertiary,
                        ),
                      )
                    : null,
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildBadge(
                          theme,
                          isSales ? "Venta" : "Compra",
                          isSales
                              ? theme.colorScheme.primary
                              : theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "${variant.conversionFactor} ${unitName ?? ''}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
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
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    isSales ? "Precio" : "Costo",
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Botón de más acciones
              IconButton(
                icon: Icon(
                  Icons.edit_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                onPressed: () => onEdit(variant, index),
                tooltip: "Editar",
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                onPressed: () => _confirmDelete(context),
                tooltip: "Eliminar",
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
