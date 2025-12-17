import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/product_variant.dart';
import '../../providers/product_form_provider.dart';
import 'variant_list_page.dart';

class VariantTypeSelectionPage extends ConsumerWidget {
  final Product product;

  const VariantTypeSelectionPage({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure the provider is initialized with the product data
    final provider = productFormProvider(product);
    // State is watched just to ensure provider ALIVE or updated?
    // Actually we don't need to watch state here if we are just a menu.
    // The VariantListPage will watch it.

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
        builder: (context) =>
            VariantListPage(product: product, filterType: type),
      ),
    );
  }
}
