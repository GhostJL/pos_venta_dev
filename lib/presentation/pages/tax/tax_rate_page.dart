import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/presentation/widgets/common/tables/custom_data_table.dart';
import 'package:posventa/presentation/widgets/catalog/tax_rates/tax_rate_form.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

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
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary.withAlpha(10),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.tertiary.withAlpha(50),
                                    ),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.tertiary,
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
                              if (hasManagePermission)
                                IconButton(
                                  icon: Icon(
                                    taxRate.isEditable
                                        ? Icons.edit_rounded
                                        : Icons.visibility_rounded,
                                    color: taxRate.isEditable
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () =>
                                      _showTaxRateDialog(context, taxRate),
                                  tooltip: taxRate.isEditable
                                      ? 'Editar'
                                      : 'Ver',
                                ),
                              if (hasManagePermission)
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: taxRate.isEditable
                                      ? () => _deleteTaxRate(
                                          context,
                                          ref,
                                          taxRate,
                                        )
                                      : null, // Disable button if not editable
                                  tooltip: taxRate.isEditable
                                      ? 'Eliminar'
                                      : 'No se puede eliminar',
                                ),
                              if (hasManagePermission && !taxRate.isDefault)
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
                                        PopupMenuItem<String>(
                                          value: 'setDefault',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
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
              onAddItem: hasManagePermission
                  ? () => _showTaxRateDialog(context)
                  : () {},
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
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              ref.read(taxRateListProvider.notifier).deleteTaxRate(taxRate.id!);
              Navigator.of(context).pop();
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
