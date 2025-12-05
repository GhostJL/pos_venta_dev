import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/widgets/common/tables/custom_data_table.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/data_table_actions.dart';
import 'package:posventa/presentation/widgets/common/tables/data_cell_text.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  SuppliersPageState createState() => SuppliersPageState();
}

class SuppliersPageState extends ConsumerState<SuppliersPage>
    with PageLifecycleMixin {
  String _searchQuery = '';

  @override
  List<dynamic> get providersToInvalidate => [supplierListProvider];

  void _navigateToForm([Supplier? supplier]) {
    context.push('/suppliers/form', extra: supplier);
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return Scaffold(
      body: AsyncValueHandler<List<Supplier>>(
        value: suppliers,
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
                        DataCell(DataCellPrimaryText(supplier.name)),
                        DataCell(
                          DataCellSecondaryText(supplier.contactPerson ?? '-'),
                        ),
                        DataCell(DataCellMonospaceText(supplier.phone ?? '-')),
                        DataCell(DataCellLinkText(supplier.email ?? '-')),
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
