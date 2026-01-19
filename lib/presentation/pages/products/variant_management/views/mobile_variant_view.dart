import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_page.dart';
import 'package:posventa/presentation/pages/products/variant_bulk_edit_page.dart';
import 'package:posventa/presentation/pages/products/variant_form/variant_form_page.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_variants_list.dart';

class MobileVariantView extends ConsumerWidget {
  final Product product;

  const MobileVariantView({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = productFormProvider(product);
    ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Gestión de Variantes',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sales Variants Section
            _buildSection(
              context,
              ref,
              title: 'Variantes de Venta',
              type: VariantType.sales,
              color: theme.colorScheme.primary,
              icon: Icons.sell_outlined,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            // Purchase Variants Section
            _buildSection(
              context,
              ref,
              title: 'Variantes de Compra',
              type: VariantType.purchase,
              color: theme.colorScheme.tertiary,
              icon: Icons.inventory_2_outlined,
            ),
            // Add extra padding at bottom for FAB if needed
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required VariantType type,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final variants = ref.read(productFormProvider(product)).variants;
    final count = variants.where((v) => v.type == type).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text('$count items', style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            // Actions (Icons for mobile to save space)
            IconButton(
              icon: const Icon(Icons.grid_4x4_rounded),
              tooltip: 'Matriz',
              onPressed: () => _openMatrixGenerator(context, ref, type),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.edit_note),
              tooltip: 'Masiva',
              onPressed: () => _openBulkEdit(context, type),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            IconButton.filled(
              onPressed: () => _openVariantForm(context, ref, type),
              icon: const Icon(Icons.add, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: color,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // List
        ProductVariantsList(
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
