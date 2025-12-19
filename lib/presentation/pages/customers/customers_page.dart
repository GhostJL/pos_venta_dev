import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';
import 'package:posventa/presentation/widgets/customers/customer_card.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  CustomersPageState createState() => CustomersPageState();
}

class CustomersPageState extends ConsumerState<CustomersPage>
    with PageLifecycleMixin {
  String _searchQuery = '';

  @override
  List<dynamic> get providersToInvalidate => [customerProvider];

  void _navigateToForm([Customer? customer]) {
    context.push('/customers/form', extra: customer);
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.customerManage),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Clientes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: AsyncValueHandler<List<Customer>>(
        value: customersAsync,
        data: (customers) {
          final filteredList = customers.where((c) {
            final query = _searchQuery.toLowerCase();
            return c.firstName.toLowerCase().contains(query) ||
                c.lastName.toLowerCase().contains(query) ||
                c.code.toLowerCase().contains(query) ||
                (c.businessName?.toLowerCase().contains(query) ?? false);
          }).toList();

          if (filteredList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron clientes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final customer = filteredList[index];
              return CustomerCard(
                customer: customer,
                hasManagePermission: hasManagePermission,
                onEdit: () => _navigateToForm(customer),
                onDelete: () => _confirmDelete(context, ref, customer),
              );
            },
          );
        },
      ),
      floatingActionButton: hasManagePermission
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo Cliente'),
            )
          : null,
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
