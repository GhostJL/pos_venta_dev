import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/domain/entities/supplier.dart';
import 'package:myapp/presentation/providers/supplier_providers.dart';
import 'package:myapp/presentation/widgets/custom_data_table.dart';
import 'package:myapp/presentation/widgets/supplier_form.dart';

class SuppliersPage extends ConsumerWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(supplierListProvider);

    void showSupplierForm({Supplier? supplier}) {
      showDialog(
        context: context,
        builder: (context) => SupplierForm(supplier: supplier),
      );
    }

    void confirmDelete(BuildContext context, WidgetRef ref, Supplier supplier) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text('¿Estás seguro de que quieres eliminar el proveedor "${supplier.name}"?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                child: const Text('Eliminar'),
                onPressed: () {
                  ref.read(supplierListProvider.notifier).removeSupplier(supplier.id!);
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomDataTable<Supplier>(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Contacto')),
            DataColumn(label: Text('Teléfono')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: suppliers.map((supplier) {
            return DataRow(
              cells: [
                DataCell(Text(supplier.name, style: Theme.of(context).textTheme.bodyLarge)),
                DataCell(Text(supplier.contactPerson ?? 'N/A', style: Theme.of(context).textTheme.bodyMedium)),
                DataCell(Text(supplier.phone ?? 'N/A', style: Theme.of(context).textTheme.bodyMedium)),
                DataCell(_buildStatusChip(supplier.isActive)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppTheme.primary, size: 20),
                        tooltip: 'Editar Proveedor',
                        onPressed: () => showSupplierForm(supplier: supplier),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: AppTheme.error, size: 20),
                        tooltip: 'Eliminar Proveedor',
                        onPressed: () => confirmDelete(context, ref, supplier),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
          itemCount: suppliers.length,
          onAddItem: () => showSupplierForm(),
          emptyText: 'No se encontraron proveedores. ¡Añade uno para empezar!',
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Chip(
      label: Text(isActive ? 'Activo' : 'Inactivo'),
      backgroundColor: isActive ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isActive ? AppTheme.success : AppTheme.error,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
