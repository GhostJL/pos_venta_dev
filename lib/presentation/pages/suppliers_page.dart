import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/widgets/supplier_form.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  SuppliersPageState createState() => SuppliersPageState();
}

class SuppliersPageState extends ConsumerState<SuppliersPage> {
  String _searchQuery = '';

  void _navigateToForm([Supplier? supplier]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierForm(supplier: supplier), // Actualizado
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return Scaffold(
      body: suppliers.when(
        data: (supplierList) {
          final filteredList = supplierList.where((s) {
            return _searchQuery.isEmpty ||
                s.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomDataTable<Supplier>(
              title: 'Proveedores',
              columns: const [
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Contacto')),
                DataColumn(label: Text('Teléfono')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: filteredList
                  .map(
                    (supplier) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            supplier.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Text(
                            supplier.contactPerson ?? '-',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            supplier.phone ?? '-',
                            style: const TextStyle(fontFamily: 'Monospace'),
                          ),
                        ),
                        DataCell(
                          Text(
                            supplier.email ?? '-',
                            style: const TextStyle(color: AppTheme.primary),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasManagePermission)
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    color: AppTheme.primary,
                                  ),
                                  onPressed: () => _navigateToForm(supplier),
                                  tooltip: 'Editar',
                                ),
                              if (hasManagePermission)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: AppTheme.error,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, ref, supplier),
                                  tooltip: 'Eliminar',
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              itemCount: filteredList.length,
              onAddItem: hasManagePermission ? () => _navigateToForm() : () {},
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
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Supplier supplier) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirmar Eliminación',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar al proveedor "${supplier.name}"?',
            style: const TextStyle(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
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
              child: const Text('Eliminar'),
              onPressed: () {
                ref
                    .read(supplierListProvider.notifier)
                    .deleteSupplier(supplier.id!);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
