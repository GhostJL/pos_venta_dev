import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/data_table_actions.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  SuppliersPageState createState() => SuppliersPageState();
}

class SuppliersPageState extends ConsumerState<SuppliersPage> {
  String _searchQuery = '';

  void _navigateToForm([Supplier? supplier]) {
    context.push('/suppliers/form', extra: supplier);
  }

  @override
  void initState() {
    super.initState();
    // Auto-refresh suppliers when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(supplierListProvider);
    });
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
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        DataCell(
                          DataTableActions(
                            hasEditPermission: hasManagePermission,
                            hasDeletePermission: hasManagePermission,
                            onEdit: () => _navigateToForm(supplier),
                            onDelete: () =>
                                _confirmDelete(context, ref, supplier),
                            editTooltip: 'Editar',
                            deleteTooltip: 'Eliminar',
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
    ConfirmDeleteDialog.show(
      context: context,
      itemName: supplier.name,
      itemType: 'el proveedor',
      onConfirm: () {
        ref.read(supplierListProvider.notifier).deleteSupplier(supplier.id!);
      },
      successMessage: 'Proveedor eliminado correctamente',
    );
  }
}
