import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;

  const CustomDataTable({Key? key, required this.columns, required this.rows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columns: columns,
              rows: rows,
              columnSpacing: 20,
              horizontalMargin: 10,
              showCheckboxColumn: false,
              dataRowMaxHeight: 50.0,
              headingRowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary.withOpacity(0.1)),
              border: TableBorder.all(
                color: Theme.of(context).dividerColor,
                width: 1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }
}
