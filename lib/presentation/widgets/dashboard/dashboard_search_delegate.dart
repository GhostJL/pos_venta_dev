import 'package:flutter/material.dart';

class DashboardSearchDelegate extends SearchDelegate<String?> {
  final List<Map<String, String>> _searchTerms = [
    {'term': 'Ventas', 'route': '/sales'},
    {'term': 'Historial de Ventas', 'route': '/sales-history'},
    {'term': 'Inventario', 'route': '/inventory'},
    {'term': 'Productos', 'route': '/products'},
    {'term': 'Clientes', 'route': '/customers'},
    {'term': 'Compras', 'route': '/purchases'},
    {'term': 'Proveedores', 'route': '/suppliers'},
    {'term': 'Categorías', 'route': '/categories'},
    {'term': 'Departamentos', 'route': '/departments'},
    {'term': 'Marcas', 'route': '/brands'},
    {'term': 'Almacenes', 'route': '/warehouses'},
    {'term': 'Cajeros', 'route': '/cashiers'},
    {'term': 'Historial de Sesiones', 'route': '/cash-sessions-history'},
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final match = _searchTerms.firstWhere(
      (element) => element['term']!.toLowerCase() == query.toLowerCase(),
      orElse: () => {},
    );

    if (match.isNotEmpty) {
      // Auto-navigate if exact match
      WidgetsBinding.instance.addPostFrameCallback((_) {
        close(context, match['route']);
      });
      return const Center(child: CircularProgressIndicator());
    }

    return _buildSuggestionsList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestionsList(context);
  }

  Widget _buildSuggestionsList(BuildContext context) {
    final suggestions = _searchTerms.where((element) {
      return element['term']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion['term']!),
          leading: const Icon(Icons.search),
          onTap: () {
            close(context, suggestion['route']);
          },
        );
      },
    );
  }
}
