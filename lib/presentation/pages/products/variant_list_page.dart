import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_page.dart';
import 'package:posventa/presentation/pages/products/variant_bulk_edit_page.dart';
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

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_4x4_rounded),
            tooltip: 'Generador de Matrices',
            onPressed: () => _openMatrixGenerator(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Edición Masiva',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VariantBulkEditPage(
                    product: product,
                    filterType: filterType,
                  ),
                ),
              );
            },
          ),
        ],
        title: Column(
          children: [
            Text(
              filterType == VariantType.sales
                  ? 'Variantes de Venta'
                  : 'Variantes de Compra',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              product.name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
                onAddVariant: (_) => _openVariantForm(context, ref, filterType),
                onEditVariant: (variant, index) => _openVariantForm(
                  context,
                  ref,
                  filterType,
                  variant: variant,
                  index: index,
                ),
                onDeleteVariant: (index) async {
                  final notifier = ref.read(provider.notifier);
                  notifier.removeVariant(index);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Eliminando variante...'),
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  }

                  final success = await notifier.validateAndSubmit(
                    silent: true,
                  );

                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Variante eliminada correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error al eliminar variante'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
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
    );
  }

  Widget _buildSummaryHeader(ThemeData theme, List<ProductVariant> variants) {
    final filteredVariants = variants
        .where((v) => v.type == filterType)
        .toList();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Text(
              '${filteredVariants.length} presentaciones configuradas',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMatrixGenerator(BuildContext context, WidgetRef ref) async {
    // 1. Prepare Data
    final existingVariants = ref.read(productFormProvider(product)).variants;

    // 2. Open Matrix Generator
    final generatedVariants = await Navigator.push<List<ProductVariant>>(
      context,
      MaterialPageRoute(
        builder: (context) => MatrixGeneratorPage(
          productId: product.id ?? 0,
          targetType: filterType,
          existingVariants: existingVariants,
        ),
      ),
    );

    if (generatedVariants != null && generatedVariants.isNotEmpty) {
      final notifier = ref.read(productFormProvider(product).notifier);

      // 2. Process Variants (Set correct type and sales flag)
      for (final variant in generatedVariants) {
        final processedVariant = variant.copyWith(
          productId: product.id,
          type: filterType,
          isForSale: filterType == VariantType.sales,
          // Ensure defaults if matrix returns nulls/zeros where unwanted
          isActive: true,
        );
        notifier.addVariant(processedVariant);
      }

      // 3. Persist Immediately
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guardando variantes generadas...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final success = await notifier.validateAndSubmit(silent: true);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${generatedVariants.length} variantes agregadas correctamente.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final error = ref.read(productFormProvider(product)).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${error ?? "Desconocido"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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

    final newVariant = await Navigator.push<ProductVariant>(
      context,
      MaterialPageRoute(
        builder: (context) => VariantFormPage(
          variant: variant,
          initialType: type,
          productId: product.id,
          productName: product.name,
          existingBarcodes: existingBarcodes,
          availableVariants: currentVariants,
        ),
      ),
    );

    if (newVariant != null) {
      // NOTE: For individual add/edit, typically we also want to persist?
      // The current flow update state, but user might need to click "Save" on previous screen?
      // VariantListPage is a standalone page. When "Back" is pressed, we return to ActionsSheet?
      // Wait, VariantListPage takes a Product. If we modify notifier here, does it persist?
      // Yes, if we call validateAndSubmit.
      // But _openVariantForm currently just updates state.
      // The original code didn't auto-save individual variants?
      // Let's stick to the requested scope: Matrix Generator updates persist immediately.

      if (variant != null && index != null) {
        ref.read(provider.notifier).updateVariant(index, newVariant);
      } else {
        ref.read(provider.notifier).addVariant(newVariant);
      }
    }
  }
}
