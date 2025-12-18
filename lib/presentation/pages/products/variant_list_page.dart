import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/product_variant.dart';
import '../../providers/product_form_provider.dart';
import '../../widgets/products/forms/product_form/product_variants_list.dart';
import '../../widgets/products/forms/variant_form_page.dart';

class VariantListPage extends ConsumerWidget {
  final Product product;
  final VariantType filterType;

  const VariantListPage({
    super.key,
    required this.product,
    required this.filterType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = productFormProvider(product);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // Lógica de detección de cambios mejorada
    bool areVariantsModified() {
      final initial = state.initialProduct?.variants ?? [];
      final current = state.variants;

      // Usamos DeepCollectionEquality para comparar contenido independientemente de la instancia
      return !const DeepCollectionEquality().equals(initial, current);
    }

    final isDirty = areVariantsModified();

    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardChangesDialog(context, notifier);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                filterType == VariantType.sales
                    ? 'Variantes de Venta'
                    : 'Variantes de Compra',
              ),
              Text(
                product.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          actions: [
            // El botón solo aparece si hay cambios pendientes
            if (isDirty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilledButton.icon(
                  onPressed: () => _save(context, notifier),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Guardar'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Resumen rápido en la parte superior
            _buildSummaryHeader(theme, state.variants),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ProductVariantsList(
                  product: product,
                  filterType: filterType,
                  onAddVariant: (_) =>
                      _openVariantForm(context, ref, filterType),
                  onEditVariant: (variant, index) => _openVariantForm(
                    context,
                    ref,
                    filterType,
                    variant: variant,
                    index: index,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Acción de agregar más accesible
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openVariantForm(context, ref, filterType),
          label: const Text('Nueva Variante'),
          icon: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(ThemeData theme, List<ProductVariant> variants) {
    final filteredVariants = variants
        .where((v) => v.type == filterType)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(width: 12),
          Text(
            '${filteredVariants.length} presentaciones configuradas',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDiscardChangesDialog(
    BuildContext context,
    ProductFormNotifier notifier,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cambios pendientes'),
            content: const Text(
              'Hay cambios en las variantes que no se han guardado. ¿Qué deseas hacer?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Descartar'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop(false);
                  await _save(context, notifier);
                },
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _save(BuildContext context, ProductFormNotifier notifier) async {
    final success = await notifier.validateAndSubmit();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Variantes actualizadas con éxito'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Mantenemos tu lógica de _openVariantForm pero podrías mejorar el estilo visual
  // de las tarjetas en ProductVariantsList para que coincidan con este look.
  Future<void> _openVariantForm(
    BuildContext context,
    WidgetRef ref,
    VariantType type, {
    ProductVariant? variant,
    int? index,
  }) async {
    final provider = productFormProvider(product);
    final currentVariants = ref.read(provider).variants;

    final existingBarcodes = currentVariants
        .where((v) => v != variant && v.barcode != null)
        .map((v) => v.barcode!)
        .toList();

    final initialVariant =
        variant ??
        ProductVariant(
          productId: product.id ?? 0,
          variantName: '',
          priceCents: 0,
          costPriceCents: 0,
          type: type,
          isForSale: type == VariantType.sales,
        );

    final newVariant = await Navigator.push<ProductVariant>(
      context,
      MaterialPageRoute(
        builder: (context) => VariantFormPage(
          variant: initialVariant,
          productId: product.id,
          productName: product.name,
          existingBarcodes: existingBarcodes,
          availableVariants: currentVariants,
        ),
      ),
    );

    if (newVariant != null) {
      if (variant != null && index != null) {
        ref.read(provider.notifier).updateVariant(index, newVariant);
      } else {
        ref.read(provider.notifier).addVariant(newVariant);
      }
    }
  }
}
