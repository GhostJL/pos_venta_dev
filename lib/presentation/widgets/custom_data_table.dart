import 'package:flutter/material.dart';

class CustomDataTable<T> extends StatelessWidget {
  final List<DataColumn> columns;
  final DataTableSource source;
  final String? title;
  final List<Widget>? actions;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.source,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PaginatedDataTable(
        header: title != null ? Text(title!) : null,
        actions: actions,
        columns: columns,
        source: source,
        rowsPerPage: 10, 
        showCheckboxColumn: false,
        columnSpacing: 20,
      ),
    );
  }
}
