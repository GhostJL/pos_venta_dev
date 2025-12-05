import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';

/// Widget for product classification section (department, category, brand, supplier)
class ProductClassificationSection extends ConsumerWidget {
  final int? selectedDepartment;
  final int? selectedCategory;
  final int? selectedBrand;
  final int? selectedSupplier;
  final ValueChanged<int?> onDepartmentChanged;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<int?> onBrandChanged;
  final ValueChanged<int?> onSupplierChanged;

  const ProductClassificationSection({
    super.key,
    required this.selectedDepartment,
    required this.selectedCategory,
    required this.selectedBrand,
    required this.selectedSupplier,
    required this.onDepartmentChanged,
    required this.onCategoryChanged,
    required this.onBrandChanged,
    required this.onSupplierChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(departmentListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final brandsAsync = ref.watch(brandListProvider);
    final suppliersAsync = ref.watch(supplierListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        departmentsAsync.when(
          data: (departments) => DropdownButtonFormField<int>(
            initialValue: selectedDepartment,
            decoration: const InputDecoration(
              labelText: 'Departamento',
              prefixIcon: Icon(Icons.category),
            ),
            items: departments
                .map(
                  (dept) =>
                      DropdownMenuItem(value: dept.id, child: Text(dept.name)),
                )
                .toList(),
            onChanged: onDepartmentChanged,
            validator: (value) => value == null ? 'Requerido' : null,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        categoriesAsync.when(
          data: (categories) => DropdownButtonFormField<int>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Categoría',
              prefixIcon: Icon(Icons.label),
            ),
            items: categories
                .map(
                  (cat) =>
                      DropdownMenuItem(value: cat.id, child: Text(cat.name)),
                )
                .toList(),
            onChanged: onCategoryChanged,
            validator: (value) => value == null ? 'Requerido' : null,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        brandsAsync.when(
          data: (brands) => DropdownButtonFormField<int>(
            initialValue: selectedBrand,
            decoration: const InputDecoration(
              labelText: 'Marca (Opcional)',
              prefixIcon: Icon(Icons.branding_watermark),
            ),
            items: brands
                .map(
                  (brand) => DropdownMenuItem(
                    value: brand.id,
                    child: Text(brand.name),
                  ),
                )
                .toList(),
            onChanged: onBrandChanged,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        suppliersAsync.when(
          data: (suppliers) => DropdownButtonFormField<int>(
            initialValue: selectedSupplier,
            decoration: const InputDecoration(
              labelText: 'Proveedor (Opcional)',
              prefixIcon: Icon(Icons.local_shipping),
            ),
            items: suppliers
                .map(
                  (supplier) => DropdownMenuItem(
                    value: supplier.id,
                    child: Text(supplier.name),
                  ),
                )
                .toList(),
            onChanged: onSupplierChanged,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }
}
