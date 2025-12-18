import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${filteredVariants.length} presentaciones configuradas',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
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
