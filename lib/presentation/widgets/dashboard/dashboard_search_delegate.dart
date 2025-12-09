import 'dart:async';
import 'package:flutter/material.dart';

class DashboardSearchDelegate extends SearchDelegate<String?> {
  DashboardSearchDelegate() : super(searchFieldLabel: 'Buscar funciones...');

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

  Timer? _debounceTimer;
  String _debouncedQuery = '';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          _debouncedQuery = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            _debounceTimer?.cancel();
            close(context, null);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ],
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

    return _buildSuggestionsList(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Debounce the search query
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _debouncedQuery = query;
    });

    // Use debounced query for suggestions
    return _buildSuggestionsList(context, _debouncedQuery);
  }

  Widget _buildSuggestionsList(BuildContext context, String searchQuery) {
    final suggestions = _searchTerms.where((element) {
      return element['term']!.toLowerCase().contains(searchQuery.toLowerCase());
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
