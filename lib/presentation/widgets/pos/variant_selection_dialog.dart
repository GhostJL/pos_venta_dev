import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/product.dart';

class VariantSelectionDialog extends StatelessWidget {
  final Product product;

  const VariantSelectionDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Seleccionar Presentación',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: product.variants?.length ?? 0,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final variant = product.variants![index];
            return ListTile(
              title: Text(
                variant.description ?? 'Sin descripción',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Factor: ${variant.quantity} | Código: ${variant.barcode ?? "N/A"}',
              ),
              trailing: Text(
                '\$${variant.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primary,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(variant);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
