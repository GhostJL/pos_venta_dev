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
    final allVariants = ref.watch(provider.select((s) => s.variants));
    final variants = allVariants.toList();

    // Filter logic
    final filteredVariants = variants.where((v) {
      if (filterType == null) return true;
      return v.type == filterType;
    }).toList();

    if (filteredVariants.isEmpty) {
      return _buildEmptyState(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint for Grid vs List
        final isWide =
            constraints.maxWidth >
            500; // Small threshold as it might be in a dialog or side panel

        if (isWide) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 110,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredVariants.length,
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_list_bulleted_outlined,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay $typeText definidas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega variantes para gestionar diferentes\nprecios, unidades o presentaciones.',
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
      color: theme.colorScheme.surfaceContainer,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      (isSales
                              ? theme.colorScheme.primary
                              : theme.colorScheme.tertiary)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
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
                          size: 20,
                          color: isSales
                              ? theme.colorScheme.primary
                              : theme.colorScheme.tertiary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _buildBadge(
                          theme,
                          "${variant.conversionFactor} ${unitName ?? ''}",
                          theme.colorScheme.secondary,
                        ),
                        _buildBadge(
                          theme,
                          "Stock: ${variant.stock ?? 0}",
                          (variant.stock ?? 0) > 0
                              ? Colors.green
                              : theme.colorScheme.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Precio / Costo Destacado
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${((isSales ? variant.priceCents : variant.costPriceCents) / 100).toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    isSales ? "Precio" : "Costo",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Botón de más acciones simple
              MenuAnchor(
                builder: (context, controller, child) {
                  return IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    tooltip: 'Opciones',
                  );
                },
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.edit_outlined),
                    onPressed: () => onEdit(variant, index),
                    child: const Text('Editar'),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => _confirmDelete(context),
                    child: Text(
                      'Eliminar',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
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
          fontSize: 10,
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
              Navigator.pop(context); // Close dialog first
              onDelete(index);
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
