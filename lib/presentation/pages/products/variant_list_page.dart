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
    // Ensure the provider is initialized with the product data
    final provider = productFormProvider(product);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // Calculate dirty state by comparing current variants with initial variants
    bool areVariantsModified() {
      final initial = state.initialProduct?.variants ?? [];
      final current = state.variants;

      if (initial.length != current.length) return true;

      // Check content equality
      for (int i = 0; i < initial.length; i++) {
        // Simple check: if objects are different instances and we replaced them on edit,
        // or if we rely on data class equality.
        // Assuming ProductVariant has equatable or == override, or we check fields.
        // If we strictly replace objects on edit, reference check might be enough if logic is immutable.
        // But let's assume == works (Equatable or manually overridden).
        if (initial[i] != current[i]) return true;
      }
      return false;
    }

    final isDirty = areVariantsModified();

    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cambios sin guardar'),
                content: const Text(
                  'Tienes cambios pendientes en las variantes. ¿Deseas salir sin guardar?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Stay
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Just exit
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Salir sin guardar'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      Navigator.of(context).pop(false); // Close dialog
                      await _save(context, notifier);
                    },
                    child: const Text('Guardar y Salir'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            filterType == VariantType.sales
                ? 'Variantes de Venta'
                : 'Variantes de Compra',
          ),
          actions: [
            // Always show save button, or only when dirty?
            // User requested: "Option to save the change".
            // Showing it always is safer UI pattern usually.
            IconButton(
              icon: const Icon(Icons.save_rounded),
              tooltip: 'Guardar Cambios',
              onPressed: () => _save(context, notifier),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
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
    );
  }

  Future<void> _save(BuildContext context, ProductFormNotifier notifier) async {
    final success = await notifier.validateAndSubmit();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados correctamente')),
      );
      // We do NOT pop here, we just persist. The "isDirty" check will recalculate to false.
    }
  }

  Future<void> _openVariantForm(
    BuildContext context,
    WidgetRef ref,
    VariantType type, {
    ProductVariant? variant,
    int? index,
  }) async {
    final provider = productFormProvider(product);
    final currentVariants = ref.read(provider).variants;

    // Get existing barcodes to prevent duplicates
    final existingBarcodes = currentVariants
        .where((v) => v != variant && v.barcode != null)
        .map((v) => v.barcode!)
        .toList();

    // Pre-configure the new variant with the selected type and productId
    final initialVariant =
        variant ??
        ProductVariant(
          productId: product.id ?? 0,
          variantName: '',
          priceCents: 0,
          costPriceCents: 0,
          type: type, // IMPLICITLY SET TYPE BASED ON SELECTION
          isForSale: type == VariantType.sales, // Default for sales is true
        );

    final newVariant = await Navigator.push<ProductVariant>(
      context,
      MaterialPageRoute(
        builder: (context) => VariantFormPage(
          variant: initialVariant,
          productId: product.id,
          productName: product.name, // Pass product name
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
