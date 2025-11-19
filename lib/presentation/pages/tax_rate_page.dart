import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/presentation/widgets/tax_rate_form.dart';

class TaxRatePage extends ConsumerStatefulWidget {
  const TaxRatePage({super.key});

  @override
  ConsumerState<TaxRatePage> createState() => _TaxRatePageState();
}

class _TaxRatePageState extends ConsumerState<TaxRatePage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final taxRates = ref.watch(taxRateListProvider);

    return Scaffold(
      body: taxRates.when(
        data: (data) {
          final filteredList = data.where((t) {
            return _searchQuery.isEmpty ||
                t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.code.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomDataTable<TaxRate>(
              title: 'Tasas de Impuestos',
              columns: const [
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Código')),
                DataColumn(label: Text('Tasa')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: filteredList
                  .map(
                    (taxRate) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            taxRate.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Text(
                            taxRate.code,
                            style: const TextStyle(fontFamily: 'Monospace'),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${(taxRate.rate * 100).toStringAsFixed(2)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        DataCell(
                          taxRate.isDefault
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.success.withOpacity(0.5),
                                    ),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(
                                      color: AppTheme.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  taxRate.isEditable
                                      ? Icons.edit_rounded
                                      : Icons.visibility_rounded,
                                  color: taxRate.isEditable
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                ),
                                onPressed: () =>
                                    _showTaxRateDialog(context, taxRate),
                                tooltip: taxRate.isEditable ? 'Editar' : 'Ver',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  color: AppTheme.error,
                                ),
                                onPressed: taxRate.isEditable
                                    ? () =>
                                          _deleteTaxRate(context, ref, taxRate)
                                    : () => _showCannotPerformOperationDialog(
                                        context,
                                        'eliminar',
                                      ),
                                tooltip: 'Eliminar',
                              ),
                              if (!taxRate.isDefault)
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'setDefault') {
                                      ref
                                          .read(taxRateListProvider.notifier)
                                          .setDefaultTaxRate(taxRate.id!);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'setDefault',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                color: AppTheme.success,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Establecer como default'),
                                            ],
                                          ),
                                        ),
                                      ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              itemCount: filteredList.length,
              onAddItem: () => _showTaxRateDialog(context),
              searchQuery: _searchQuery,
              onSearch: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showTaxRateDialog(BuildContext context, [TaxRate? taxRate]) {
    showDialog(
      context: context,
      builder: (context) => TaxRateForm(taxRate: taxRate),
    );
  }

  void _deleteTaxRate(BuildContext context, WidgetRef ref, TaxRate taxRate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar Tasa de Impuesto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('¿Está seguro que desea eliminar "${taxRate.name}"?'),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              ref.read(taxRateListProvider.notifier).deleteTaxRate(taxRate.id!);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCannotPerformOperationDialog(
    BuildContext context,
    String operation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Operación no permitida',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Esta tasa de impuesto es predefinida y no se puede $operation.',
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
