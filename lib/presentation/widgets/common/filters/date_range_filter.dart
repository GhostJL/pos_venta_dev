import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable date range filter widget with picker and display.
///
/// This widget provides a consistent way to filter data by date range
/// across the application.
///
/// Example usage:
/// ```dart
/// DateRangeFilter(
///   startDate: _startDate,
///   endDate: _endDate,
///   onDateRangeChanged: (start, end) {
///     setState(() {
///       _startDate = start;
///       _endDate = end;
///     });
///   },
/// )
/// ```
class DateRangeFilter extends StatelessWidget {
  /// The currently selected start date
  final DateTime? startDate;

  /// The currently selected end date
  final DateTime? endDate;

  /// Callback when date range changes (both dates can be null when cleared)
  final void Function(DateTime? start, DateTime? end) onDateRangeChanged;

  /// The earliest date that can be selected
  final DateTime? firstDate;

  /// The latest date that can be selected
  final DateTime? lastDate;

  /// Custom date format for display (defaults to 'dd/MM')
  final String? dateFormat;

  /// Tooltip for the filter button
  final String? filterTooltip;

  /// Tooltip for the clear button
  final String? clearTooltip;

  const DateRangeFilter({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
    this.filterTooltip,
    this.clearTooltip,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeChanged(picked.start, picked.end);
    }
  }

  void _clearDateRange() {
    onDateRangeChanged(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasDateRange = startDate != null && endDate != null;
    final format = dateFormat ?? 'dd/MM';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDateRange)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${DateFormat(format).format(startDate!)} - ${DateFormat(format).format(endDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        IconButton(
          icon: Icon(
            hasDateRange ? Icons.close : Icons.filter_list_outlined,
            size: 22,
          ),
          onPressed: hasDateRange
              ? _clearDateRange
              : () => _selectDateRange(context),
          tooltip: hasDateRange
              ? (clearTooltip ?? 'Limpiar filtro')
              : (filterTooltip ?? 'Filtrar por fecha'),
        ),
      ],
    );
  }
}
