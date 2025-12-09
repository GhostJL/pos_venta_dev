import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product_variant.dart';

/// Widget for displaying and managing product variants list
class ProductVariantsList extends StatelessWidget {
  final List<ProductVariant> variants;
  final VoidCallback onAddVariant;
  final void Function(ProductVariant variant, int index) onEditVariant;
  final void Function(int index) onDeleteVariant;

  const ProductVariantsList({
    super.key,
    required this.variants,
    required this.onAddVariant,
    required this.onEditVariant,
    required this.onDeleteVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          if (variants.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No hay variantes adicionales. Se usará la configuración principal.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: variants.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final variant = variants[index];
                return ListTile(
                  title: Text(
                    variant.variantName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${variant.quantity} unidades - \$${(variant.priceCents / 100).toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditVariant(variant, index),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: () => onDeleteVariant(index),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: onAddVariant,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Variante'),
            ),
          ),
        ],
      ),
    );
  }
}
