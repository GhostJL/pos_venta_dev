import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/widgets/brand_form.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';

class BrandsPage extends ConsumerWidget {
  const BrandsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandList = ref.watch(brandListProvider);

    void showForm([Brand? brand]) {
      showDialog(
        context: context,
        builder: (context) => BrandForm(brand: brand),
      );
    }

    void confirmDelete(BuildContext context, WidgetRef ref, Brand brand) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text(
              '¿Estás seguro de que quieres eliminar la marca "${brand.name}"?',
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
                  ref.read(brandListProvider.notifier).deleteBrand(brand.id!);
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
        child: brandList.when(
          data: (brands) => CustomDataTable<Brand>(
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Código')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: brands.map((brand) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      brand.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  DataCell(
                    Text(
                      brand.code,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  DataCell(_buildStatusChip(brand.isActive)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          tooltip: 'Editar Marca',
                          onPressed: () => showForm(brand),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: AppTheme.error,
                            size: 20,
                          ),
                          tooltip: 'Eliminar Marca',
                          onPressed: () => confirmDelete(context, ref, brand),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
            itemCount: brands.length,
            onAddItem: () => showForm(),
            emptyText: 'No se encontraron marcas. ¡Añade una para empezar!',
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Chip(
      label: Text(isActive ? 'Activo' : 'Inactivo'),
      backgroundColor: isActive
          ? AppTheme.success.withAlpha(10)
          : AppTheme.error.withAlpha(10),
      labelStyle: TextStyle(
        color: isActive ? AppTheme.success : AppTheme.error,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
