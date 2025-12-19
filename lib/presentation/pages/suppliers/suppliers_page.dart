import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';
import 'package:posventa/presentation/widgets/suppliers/supplier_card.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Proveedores',
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
                hintText: 'Buscar proveedores...',
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
      body: AsyncValueHandler<List<Supplier>>(
        value: suppliers,
        data: (supplierList) {
          final filteredList = supplierList.where((s) {
            return _searchQuery.isEmpty ||
                s.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_rounded,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron proveedores',
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
              final supplier = filteredList[index];
              return SupplierCard(
                supplier: supplier,
                hasManagePermission: hasManagePermission,
                onEdit: () => _navigateToForm(supplier),
                onDelete: () => _confirmDelete(context, ref, supplier),
              );
            },
          );
        },
      ),
      floatingActionButton: hasManagePermission
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo Proveedor'),
            )
          : null,
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
