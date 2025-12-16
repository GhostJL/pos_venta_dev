import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_variants_list.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form_page.dart';

class VariantTypeSelectionPage extends ConsumerWidget {
  final Product product;

  const VariantTypeSelectionPage({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure the provider is initialized with the product data
    final provider = productFormProvider(product);
    // We access the state just to ensure it's built/available
    // ignore: unused_local_variable
    final state = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Variantes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Seleccione el tipo de variante a gestionar para:\n${product.name}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildSelectionCard(
              context,
              title: 'Variantes de Venta',
              icon: Icons.sell,
              color: Colors.blue,
              description: 'Gestionar presentaciones para la venta al público.',
              onTap: () =>
                  _navigateToVariantList(context, ref, VariantType.sales),
            ),
            const SizedBox(height: 24),
            _buildSelectionCard(
              context,
              title: 'Variantes de Compra',
              icon: Icons.inventory,
              color: Colors.green,
              description: 'Gestionar cajas o paquetes para abastecimiento.',
              onTap: () =>
                  _navigateToVariantList(context, ref, VariantType.purchase),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToVariantList(
    BuildContext context,
    WidgetRef ref,
    VariantType type,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              type == VariantType.sales
                  ? 'Variantes de Venta'
                  : 'Variantes de Compra',
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ProductVariantsList(
              product: product,
              filterType: type,
              onAddVariant: (_) => _openVariantForm(context, ref, type),
              onEditVariant: (variant, index) => _openVariantForm(
                context,
                ref,
                type,
                variant: variant,
                index: index,
              ),
            ),
          ),
        ),
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
