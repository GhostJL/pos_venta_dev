import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:intl/intl.dart';

/// Widget reutilizable para filtros de búsqueda de transacciones
class TransactionFiltersWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final VoidCallback onDateRangePressed;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onSearchChanged;

  const TransactionFiltersWidget({
    super.key,
    this.startDate,
    this.endDate,
    this.searchQuery,
    required this.onDateRangePressed,
    required this.onClearFilters,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final hasFilters =
        startDate != null ||
        endDate != null ||
        (searchQuery?.isNotEmpty ?? false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por número de venta o cliente...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.textSecondary,
              ),
              filled: true,
              fillColor: AppTheme.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter buttons row
          Row(
            children: [
              // Date range button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDateRangePressed,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    startDate != null && endDate != null
                        ? '${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}'
                        : 'Seleccionar fechas',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(
                      color: startDate != null
                          ? AppTheme.primary
                          : AppTheme.borders,
                      width: startDate != null ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              if (hasFilters) ...[
                const SizedBox(width: 8),
                // Clear filters button
                IconButton(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Limpiar filtros',
                  style: IconButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
