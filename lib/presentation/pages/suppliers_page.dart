import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/widgets/supplier_form.dart'; // Actualizado
import 'package:posventa/presentation/providers/supplier_providers.dart';

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

  void _confirmDelete(BuildContext context, WidgetRef ref, Supplier supplier) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar al proveedor "${supplier.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                ref.read(supplierListProvider.notifier).deleteSupplier(supplier.id!);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: suppliers.when(
                data: (supplierList) {
                  final filteredList = supplierList.where((s) {
                    return _searchQuery.isEmpty ||
                        s.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                  }).toList();

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Nombre de Contacto')),
                          DataColumn(label: Text('Teléfono')),
                          DataColumn(label: Text('Correo Electrónico')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: filteredList
                            .map(
                              (supplier) => DataRow(
                                cells: [
                                  DataCell(Text(supplier.name)),
                                  DataCell(Text(supplier.contactPerson ?? '-')),
                                  DataCell(Text(supplier.phone ?? '-')),
                                  DataCell(Text(supplier.email ?? '-')),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              _navigateToForm(supplier),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () =>
                                              _confirmDelete(context, ref, supplier),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
