import 'package:flutter/material.dart';

class GenericModuleListPage<T> extends StatefulWidget {
  final String title;
  final IconData? emptyIcon;
  final String emptyMessage;
  final String? addButtonLabel;
  final VoidCallback? onAddPressed;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool isLoading;
  final String? filterPlaceholder;
  final bool Function(T item, String query)? filterCallback;

  const GenericModuleListPage({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.emptyIcon,
    this.emptyMessage = 'No se encontraron elementos',
    this.addButtonLabel,
    this.onAddPressed,
    this.isLoading = false,
    this.filterPlaceholder = 'Buscar...',
    this.filterCallback,
  });

  @override
  State<GenericModuleListPage<T>> createState() =>
      _GenericModuleListPageState<T>();
}

class _GenericModuleListPageState<T> extends State<GenericModuleListPage<T>> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    // Filter items
    final filteredItems =
        widget.filterCallback != null && _searchQuery.isNotEmpty
        ? widget.items
              .where((item) => widget.filterCallback!(item, _searchQuery))
              .toList()
        : widget.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
        actions: [
          if (widget.onAddPressed != null && !isTablet)
            IconButton(
              onPressed: widget.onAddPressed,
              icon: const Icon(Icons.add),
              tooltip: widget.addButtonLabel ?? 'Añadir',
            ),
          if (widget.onAddPressed != null && isTablet)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FilledButton.icon(
                onPressed: widget.onAddPressed,
                icon: const Icon(Icons.add),
                label: Text(widget.addButtonLabel ?? 'Añadir'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.filterCallback != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SearchBar(
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                ),
                hintText: widget.filterPlaceholder,
                leading: const Icon(Icons.search_rounded),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                ? _buildEmptyState(context)
                : _buildContent(context, filteredItems, isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<T> items, bool isTablet) {
    if (isTablet) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3.5, // Adjusted for card height
        ),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            widget.itemBuilder(context, items[index]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          widget.itemBuilder(context, items[index]),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.emptyIcon ?? Icons.inbox_rounded,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.onAddPressed != null && _searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: widget.onAddPressed,
              icon: const Icon(Icons.add),
              label: Text(widget.addButtonLabel ?? 'Añadir nuevo'),
            ),
          ],
        ],
      ),
    );
  }
}
