import 'package:flutter/material.dart';

class CustomDataTableContent extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool isSmallScreen;

  const CustomDataTableContent({
    super.key,
    required this.columns,
    required this.rows,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
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
                columns: _buildStyledColumns(context),
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
                    return Theme.of(context).colorScheme.primary.withAlpha(10);
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

  List<DataColumn> _buildStyledColumns(BuildContext context) {
    return columns.map((col) {
      return DataColumn(
        label: DefaultTextStyle(
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
          child: col.label,
        ),
      );
    }).toList();
  }
}
