import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/entities/brand.dart';
import 'package:myapp/presentation/providers/brand_providers.dart';
import 'package:myapp/presentation/widgets/custom_data_table.dart';
import 'package:myapp/presentation/widgets/brand_form.dart';

class BrandsPage extends ConsumerWidget {
  const BrandsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandList = ref.watch(brandListProvider);
    final textTheme = Theme.of(context).textTheme;

    void showForm([Brand? brand]) {
      showDialog(
        context: context,
        builder: (context) => BrandForm(brand: brand),
      );
    }

    void confirmDelete(BuildContext context, WidgetRef ref, Brand brand) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text(
              '¿Estás seguro de que deseas eliminar la marca "${brand.name}"?',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Eliminar'),
                onPressed: () {
                  ref.read(brandListProvider.notifier).deleteBrand(brand.id!);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestión de Marcas', style: textTheme.headlineMedium),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Añadir Marca'),
                onPressed: () => showForm(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: brandList.when(
                data: (brands) {
                  return brands.isEmpty
                      ? const Center(child: Text('No hay marcas registradas.'))
                      : CustomDataTable(
                          columns: const [
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Código')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: brands.map((brand) {
                            return DataRow(
                              cells: [
                                DataCell(Text(brand.name)),
                                DataCell(Text(brand.code)),
                                DataCell(
                                  Switch(
                                    value: brand.isActive,
                                    onChanged: (value) {
                                      final updatedBrand = brand.copyWith(
                                        isActive: value,
                                      );
                                      ref
                                          .read(brandListProvider.notifier)
                                          .updateBrand(updatedBrand);
                                    },
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => showForm(brand),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            confirmDelete(context, ref, brand),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
