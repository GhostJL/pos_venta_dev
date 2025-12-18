import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'variant_list_page.dart';

class VariantTypeSelectionPage extends ConsumerWidget {
  final Product product;

  const VariantTypeSelectionPage({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alineación limpia
            children: [
              const SizedBox(height: 20),
              _buildProductHeader(theme),
              const SizedBox(height: 48),

              Text(
                'Seleccione una categoría',
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Opciones minimalistas
              _buildModernOption(
                context,
                title: 'Canal de Venta',
                subtitle: 'Venta al público y presentaciones de salida.',
                icon: Icons.sell_outlined,
                onTap: () => _navigateToVariantList(context, VariantType.sales),
              ),

              const SizedBox(height: 12),

              _buildModernOption(
                context,
                title: 'Abastecimiento',
                subtitle: 'Gestión de compras y unidades de entrada.',
                icon: Icons.inventory_2_outlined,
                onTap: () =>
                    _navigateToVariantList(context, VariantType.purchase),
              ),

              const Spacer(),
              _buildHelpFooter(theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'CÓDIGO: ${product.code}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: Colors.blue[700]),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpFooter(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Las variantes permiten manejar diferentes unidades de medida para un mismo producto.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  void _navigateToVariantList(BuildContext context, VariantType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VariantListPage(product: product, filterType: type),
      ),
    );
  }
}
