import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
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
            icon: const Icon(Icons.edit_note),
            tooltip: 'Edición Masiva',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VariantBulkEditPage(product: product),
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
