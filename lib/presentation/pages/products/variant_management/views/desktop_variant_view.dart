import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_page.dart';
import 'package:posventa/presentation/pages/products/variant_bulk_edit_page.dart';
import 'package:posventa/presentation/pages/products/variant_form/variant_form_page.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_variants_list.dart';

class DesktopVariantView extends ConsumerWidget {
  final Product product;

  const DesktopVariantView({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = productFormProvider(product);
    ref.watch(provider); // Watch for updates

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sales Variants Panel
            Expanded(
              child: _buildVariantPanel(
                context,
                ref,
                title: 'Variantes de Venta',
                type: VariantType.sales,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            const VerticalDivider(),
            const SizedBox(width: 16),
            // Purchase Variants Panel
            Expanded(
              child: _buildVariantPanel(
                context,
                ref,
                title: 'Variantes de Abastecimiento',
                type: VariantType.purchase,
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantPanel(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required VariantType type,
    required Color color,
  }) {
    final theme = Theme.of(context);

    // Count variants of this type
    final variants = ref.read(productFormProvider(product)).variants;
    final count = variants.where((v) => v.type == type).length;

    return Column(
      children: [
        // Header with Actions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(
                type == VariantType.sales
                    ? Icons.sell_outlined
                    : Icons.inventory_2_outlined,
                color: color,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '$count configuradas',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Actions
              IconButton(
                icon: const Icon(Icons.grid_4x4_rounded),
                tooltip: 'Generador de Matrices',
                onPressed: () => _openMatrixGenerator(context, ref, type),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note),
                tooltip: 'Edición Masiva',
                onPressed: () => _openBulkEdit(context, type),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _openVariantForm(context, ref, type),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // List
        Expanded(
          child: SingleChildScrollView(
            child: ProductVariantsList(
              product: product,
              filterType: type,
              onEditVariant: (variant, index) => _openVariantForm(
                context,
                ref,
                type,
                variant: variant,
                index: index,
              ),
              onDeleteVariant: (index) => _deleteVariant(context, ref, index),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMatrixGenerator(
    BuildContext context,
    WidgetRef ref,
    VariantType type,
  ) async {
    final existingVariants = ref.read(productFormProvider(product)).variants;

    final generatedVariants = await Navigator.push<List<ProductVariant>>(
      context,
      MaterialPageRoute(
        builder: (context) => MatrixGeneratorPage(
          productId: product.id ?? 0,
          targetType: type,
          existingVariants: existingVariants,
        ),
      ),
    );

    if (generatedVariants != null && generatedVariants.isNotEmpty) {
      final notifier = ref.read(productFormProvider(product).notifier);

      for (final variant in generatedVariants) {
        final processedVariant = variant.copyWith(
          productId: product.id,
          type: type,
          isForSale: type == VariantType.sales,
          isActive: true,
        );
        notifier.addVariant(processedVariant);
      }

      await notifier.validateAndSubmit(silent: true);
    }
  }

  void _openBulkEdit(BuildContext context, VariantType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VariantBulkEditPage(product: product, filterType: type),
      ),
    );
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
      final notifier = ref.read(provider.notifier);
      if (variant != null && index != null) {
        notifier.updateVariant(index, newVariant);
      } else {
        notifier.addVariant(newVariant);
      }
      // Save changes immediately for better UX
      notifier.validateAndSubmit(silent: true);
    }
  }

  Future<void> _deleteVariant(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final notifier = ref.read(productFormProvider(product).notifier);
    notifier.removeVariant(index);
    await notifier.validateAndSubmit(silent: true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Variante eliminada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
