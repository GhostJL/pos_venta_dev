import 'package:flutter/material.dart';
import 'package:posventa/app/theme.dart';

class CustomDataTable<T> extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int itemCount;
  final VoidCallback onAddItem;
  final String emptyText;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.itemCount,
    required this.onAddItem,
    this.emptyText = 'No se encontraron artículos.',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            side: const BorderSide(color: AppTheme.borders, width: 1),
          ),
          child: Column(
            children: [
              _buildHeader(context, isSmallScreen),
              const Divider(height: 1, thickness: 1),
              if (itemCount == 0)
                _buildEmptyState(context, isSmallScreen)
              else
                _buildTable(context, isSmallScreen),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, bool isSmallScreen) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(isSmallScreen ? 12 : 16),
        bottomRight: Radius.circular(isSmallScreen ? 12 : 16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Theme(
            data: Theme.of(
              context,
            ).copyWith(dividerColor: AppTheme.borders.withAlpha(50)),
            child: DataTable(
              columns: columns.map((col) {
                return DataColumn(
                  label: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    child: col.label,
                  ),
                );
              }).toList(),
              rows: rows,
              headingRowColor: WidgetStateProperty.all(
                AppTheme.inputBackground.withAlpha(30),
              ),
              headingRowHeight: isSmallScreen ? 44 : 48,
              dataRowMinHeight: isSmallScreen ? 48 : 56,
              dataRowMaxHeight: isSmallScreen ? 64 : 72,
              horizontalMargin: isSmallScreen ? 12 : 20,
              columnSpacing: isSmallScreen ? 16 : 24,
              showBottomBorder: false,
              dataRowColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.hovered)) {
                  return AppTheme.inputBackground.withAlpha(50);
                }
                return Colors.transparent;
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12.0 : 20.0,
        vertical: isSmallScreen ? 12.0 : 16.0,
      ),
      child: isSmallScreen
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getEntityName(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$itemCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: onAddItem,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Agregar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _getEntityName(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$itemCount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Material(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onAddItem,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Agregar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 40.0 : 64.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.inputBackground.withAlpha(50),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: isSmallScreen ? 40 : 48,
              color: AppTheme.textSecondary.withAlpha(60),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            emptyText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: isSmallScreen ? 14 : 15,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'Comienza agregando un nuevo elemento',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary.withAlpha(70),
              fontSize: isSmallScreen ? 12 : 13,
            ),
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
