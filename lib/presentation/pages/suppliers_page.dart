import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/entities/supplier.dart';
import 'package:myapp/presentation/providers/supplier_providers.dart';
import 'package:myapp/presentation/widgets/custom_data_table.dart';
import 'package:myapp/presentation/widgets/supplier_form.dart';

class SuppliersPage extends ConsumerWidget {
  const SuppliersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(supplierListProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestión de Proveedores', style: textTheme.headlineMedium),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Añadir Proveedor'),
                onPressed: () => _showSupplierForm(context, ref),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: suppliers.isEmpty
                  ? const Center(child: Text('No hay proveedores registrados. ¡Añade uno para empezar!'))
                  : CustomDataTable(
                      columns: const [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Código')),
                        DataColumn(label: Text('Contacto')),
                        DataColumn(label: Text('Teléfono')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: suppliers.map((supplier) {
                        return DataRow(
                          cells: [
                            DataCell(Text(supplier.name)),
                            DataCell(Text(supplier.code)),
                            DataCell(Text(supplier.contactPerson ?? 'N/A')),
                            DataCell(Text(supplier.phone ?? 'N/A')),
                            DataCell(Text(supplier.email ?? 'N/A')),
                            DataCell(
                              Switch(
                                value: supplier.isActive,
                                onChanged: (value) {
                                  final updatedSupplier = supplier.copyWith(
                                    isActive: value,
                                  );
                                  ref
                                      .read(supplierListProvider.notifier)
                                      .editSupplier(updatedSupplier);
                                },
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Editar Proveedor',
                                    onPressed: () => _showSupplierForm(
                                      context,
                                      ref,
                                      supplier: supplier,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Eliminar Proveedor',
                                    onPressed: () =>
                                        _confirmDelete(context, ref, supplier),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupplierForm(
    BuildContext context,
    WidgetRef ref, {
    Supplier? supplier,
  }) {
    showDialog(
      context: context,
      builder: (context) => SupplierForm(supplier: supplier),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Supplier supplier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar al proveedor "${supplier.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                ref
                    .read(supplierListProvider.notifier)
                    .removeSupplier(supplier.id!);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
