import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/presentation/widgets/customer_form.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  CustomersPageState createState() => CustomersPageState();
}

class CustomersPageState extends ConsumerState<CustomersPage> {
  String _searchQuery = '';

  void _navigateToForm([Customer? customer]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomerForm(customer: customer)),
    );
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasManagePermission)
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppTheme.primary,
                              ),
                              onPressed: () => _navigateToForm(customer),
                            ),
                          if (hasManagePermission)
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppTheme.error,
                              ),
                              onPressed: () =>
                                  _confirmDelete(context, ref, customer),
                            ),
                        ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Eliminar cliente ${customer.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              ref.read(customerProvider.notifier).deleteCustomer(customer.id!);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
