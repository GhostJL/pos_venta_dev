import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';

/// Widget for searching products with autocomplete and barcode scanner
class ProductSearchBar extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductSelected;
  final VoidCallback onScanPressed;

  const ProductSearchBar({
    super.key,
    required this.products,
    required this.onProductSelected,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Autocomplete<Product>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Product>.empty();
              }
              return products.where((product) {
                final searchText = textEditingValue.text.toLowerCase();
                return product.name.toLowerCase().contains(searchText) ||
                    (product.barcode?.contains(textEditingValue.text) ?? false);
              });
            },
            displayStringForOption: (Product option) => option.name,
            onSelected: onProductSelected,
            fieldViewBuilder:
                (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Buscar Producto',
                      hintText: 'Nombre o Código de Barras',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: controller.clear,
                            )
                          : null,
                    ),
                    onEditingComplete: onEditingComplete,
                  );
                },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                      maxWidth: 400,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final product = options.elementAt(index);
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                            'Costo: \$${(product.costPriceCents / 100).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () => onSelected(product),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: onScanPressed,
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'Escanear código de barras',
          style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
      ],
    );
  }
}
