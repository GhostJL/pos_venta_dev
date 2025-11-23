import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/data_table_actions.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  CustomersPageState createState() => CustomersPageState();
}

class CustomersPageState extends ConsumerState<CustomersPage> {
  String _searchQuery = '';

  void _navigateToForm([Customer? customer]) {
    context.push('/customers/form', extra: customer);
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.customerManage),
    );

    return Scaffold(
      body: customersAsync.when(
        data: (customers) {
          final filteredList = customers.where((c) {
            final query = _searchQuery.toLowerCase();
            return c.firstName.toLowerCase().contains(query) ||
                c.lastName.toLowerCase().contains(query) ||
                c.code.toLowerCase().contains(query) ||
                (c.businessName?.toLowerCase().contains(query) ?? false);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomDataTable<Customer>(
              title: 'Clientes',
              columns: const [
                DataColumn(label: Text('Código')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Teléfono')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: filteredList.map((customer) {
                return DataRow(
                  cells: [
                    DataCell(Text(customer.code)),
                    DataCell(Text(customer.fullName)),
                    DataCell(Text(customer.phone ?? '-')),
                    DataCell(Text(customer.email ?? '-')),
                    DataCell(
                      DataTableActions(
                        hasEditPermission: hasManagePermission,
                        hasDeletePermission: hasManagePermission,
                        onEdit: () => _navigateToForm(customer),
                        onDelete: () => _confirmDelete(context, ref, customer),
                      ),
                    ),
                  ],
                );
              }).toList(),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, Customer customer) {
    ConfirmDeleteDialog.show(
      context: context,
      itemName: customer.fullName,
      itemType: 'el cliente',
      onConfirm: () {
        ref.read(customerProvider.notifier).deleteCustomer(customer.id!);
      },
      successMessage: 'Cliente eliminado correctamente',
    );
  }
}
