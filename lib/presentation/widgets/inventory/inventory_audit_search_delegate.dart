import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';

class InventoryAuditSearchDelegate
    extends SearchDelegate<InventoryAuditItemEntity?> {
  final List<InventoryAuditItemEntity> items;

  InventoryAuditSearchDelegate(this.items);

  @override
  String get searchFieldLabel => 'Buscar producto...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultsList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResultsList(context);
  }

  Widget _buildResultsList(BuildContext context) {
    final cleanQuery = query.toLowerCase().trim();

    if (cleanQuery.isEmpty) {
      return const Center(child: Text('Ingrese nombre o código del producto'));
    }

    final filteredItems = items.where((item) {
      final name = item.productName?.toLowerCase() ?? '';
      final variant = item.variantName?.toLowerCase() ?? '';
      final barcode = item.barcode?.toLowerCase() ?? '';
      // We could also search by internal ID if needed
      return name.contains(cleanQuery) ||
          variant.contains(cleanQuery) ||
          barcode.contains(cleanQuery);
    }).toList();

    if (filteredItems.isEmpty) {
      return const Center(child: Text('No se encontraron productos'));
    }

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: Text(
            item.variantName != null
                ? '${item.productName} - ${item.variantName}'
                : item.productName ?? 'Sin Nombre',
          ),
          subtitle: Text(
            '${item.barcode ?? 'Sin Código'} | Actual: ${item.countedQuantity}',
          ),
          onTap: () {
            close(context, item);
          },
        );
      },
    );
  }
}
