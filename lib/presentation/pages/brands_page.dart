import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/entities/brand.dart';
import 'package:myapp/presentation/providers/brand_providers.dart';
import 'package:myapp/presentation/widgets/custom_data_table.dart';
import 'package:myapp/presentation/widgets/brand_form.dart';
import 'package:myapp/presentation/widgets/brand_list_tile.dart';

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

    return Scaffold(
      body: brandList.when(
        data: (brands) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Use ListView for smaller screens
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    return BrandListTile(
                      brand: brand,
                      onEdit: () => showForm(brand),
                      onDelete: () => ref
                          .read(brandListProvider.notifier)
                          .deleteBrand(brand.id!),
                    );
                  },
                );
              } else {
                // Use DataTable for larger screens
                return CustomDataTable<Brand>(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Code')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  source: _BrandDataSource(brands, ref, showForm),
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BrandDataSource extends DataTableSource {
  final List<Brand> brands;
  final WidgetRef ref;
  final void Function(Brand) onEdit;

  _BrandDataSource(this.brands, this.ref, this.onEdit);

  @override
  DataRow? getRow(int index) {
    final brand = brands[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(brand.name)),
        DataCell(Text(brand.code)),
        DataCell(Text(brand.isActive ? 'Active' : 'Inactive')),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEdit(brand),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () =>
                    ref.read(brandListProvider.notifier).deleteBrand(brand.id!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => brands.length;

  @override
  int get selectedRowCount => 0;
}
