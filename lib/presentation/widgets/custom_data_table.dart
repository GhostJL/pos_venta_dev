import 'package:flutter/material.dart';
import 'package:posventa/app/theme.dart';

class CustomDataTable<T> extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int itemCount;
  final VoidCallback onAddItem;
  final String emptyText;
  final String? title;
  final String? searchQuery;
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
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textPrimary.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, isSmallScreen),
              if (itemCount == 0 &&
                  (searchQuery == null || searchQuery!.isEmpty))
                Expanded(child: _buildEmptyState(context, isSmallScreen))
              else
                Expanded(child: _buildTable(context, isSmallScreen)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, bool isSmallScreen) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth:
                  MediaQuery.of(context).size.width - (isSmallScreen ? 32 : 64),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                dividerTheme: const DividerThemeData(color: Colors.transparent),
              ),
              child: DataTable(
                columns: columns.map((col) {
                  return DataColumn(
                    label: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                      child: col.label,
                    ),
                  );
                }).toList(),
                rows: rows,
                headingRowColor: WidgetStateProperty.all(Colors.transparent),
                headingRowHeight: 56,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 72,
                horizontalMargin: 24,
                columnSpacing: 24,
                showBottomBorder: false,
                dataRowColor: WidgetStateProperty.resolveWith<Color>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.hovered)) {
                    return AppTheme.primary.withOpacity(0.05);
                  }
                  return Colors.transparent;
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSmallScreen) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title ?? _getEntityName(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                _buildCountBadge(),
              ],
            ),
            const SizedBox(height: 16),
            if (onSearch != null) ...[
              _buildSearchBar(),
              const SizedBox(height: 16),
            ],
            SizedBox(width: double.infinity, child: _buildAddButton(context)),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title ?? _getEntityName(),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(width: 12),
                    _buildCountBadge(),
                  ],
                ),
                Row(
                  children: [
                    if (onSearch != null) ...[
                      SizedBox(width: 250, child: _buildSearchBar()),
                      const SizedBox(width: 16),
                    ],
                    _buildAddButton(context),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: onSearch,
      decoration: InputDecoration(
        hintText: 'Buscar...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppTheme.textSecondary,
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$itemCount',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onAddItem,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: const Text('Agregar Nuevo'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 40.0 : 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.background,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppTheme.textSecondary.withAlpha(100),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            emptyText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza agregando un nuevo elemento a la lista',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getEntityName() {
    if (T.toString() == 'Department') return 'Departamentos';
    if (T.toString() == 'Category') return 'Categorías';
    if (T.toString() == 'Brand') return 'Marcas';
    if (T.toString() == 'Supplier') return 'Proveedores';
    return 'Artículos';
  }
}
