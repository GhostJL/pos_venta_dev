import 'package:flutter/material.dart';
import 'custom_data_table_widgets/custom_data_table_header.dart';
import 'custom_data_table_widgets/custom_data_table_content.dart';
import 'custom_data_table_widgets/custom_data_table_empty_state.dart';

/// A reusable data table widget with search, add functionality, and responsive design.
///
/// This widget provides a consistent UI for displaying tabular data across the application.
/// It includes:
/// - Responsive layout (mobile and desktop)
/// - Search functionality
/// - Add new item button
/// - Empty state display
/// - Styled data table with hover effects
class CustomDataTable<T> extends StatelessWidget {
  /// The columns to display in the data table
  final List<DataColumn> columns;

  /// The rows of data to display
  final List<DataRow> rows;

  /// Total count of items (used for the badge display)
  final int itemCount;

  /// Callback when the add button is pressed
  final VoidCallback onAddItem;

  /// Text to display when there are no items
  final String emptyText;

  /// Optional title for the table (defaults to entity name based on type T)
  final String? title;

  /// Current search query (used to determine if empty state should show)
  final String? searchQuery;

  /// Callback when search text changes
  final ValueChanged<String>? onSearch;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.itemCount,
    required this.onAddItem,
    this.emptyText = 'No se encontraron artículos.',
    this.title,
    this.searchQuery,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomDataTableHeader(
                title: title ?? _getEntityName(),
                itemCount: itemCount,
                isSmallScreen: isSmallScreen,
                onSearch: onSearch,
                onAddItem: onAddItem,
              ),
              if (_shouldShowEmptyState())
                Expanded(
                  child: CustomDataTableEmptyState(
                    emptyText: emptyText,
                    isSmallScreen: isSmallScreen,
                  ),
                )
              else
                Expanded(
                  child: CustomDataTableContent(
                    columns: columns,
                    rows: rows,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Determines if the empty state should be displayed
  bool _shouldShowEmptyState() {
    return itemCount == 0 && (searchQuery == null || searchQuery!.isEmpty);
  }

  /// Gets the default entity name based on the generic type T
  String _getEntityName() {
    if (T.toString() == 'Department') return 'Departamentos';
    if (T.toString() == 'Category') return 'Categorías';
    if (T.toString() == 'Brand') return 'Marcas';
    if (T.toString() == 'Supplier') return 'Proveedores';
    return 'Artículos';
  }
}
