import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/widgets/catalog/brands/brand_form.dart';
import 'package:posventa/presentation/widgets/catalog/categories/category_form.dart';
import 'package:posventa/presentation/widgets/catalog/departments/department_form.dart';
import 'package:posventa/presentation/widgets/catalog/suppliers/supplier_form.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/domain/entities/supplier.dart';

/// Widget for product classification section (department, category, brand, supplier)
class ProductClassificationSection extends ConsumerWidget {
  final Product? product;

  const ProductClassificationSection({super.key, required this.product});

  Future<void> _openDepartmentForm(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => const Dialog(child: DepartmentForm(isDialog: true)),
    );
    if (result != null) {
      ref.read(productFormProvider(product).notifier).setDepartment(result);
    }
  }

  Future<void> _openCategoryForm(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => const Dialog(child: CategoryForm(isDialog: true)),
    );
    if (result != null) {
      ref.read(productFormProvider(product).notifier).setCategory(result);
    }
  }

  Future<void> _openBrandForm(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Brand>(
      context: context,
      builder: (context) => const Dialog(child: BrandForm(isDialog: true)),
    );
    if (result != null && result.id != null) {
      ref.read(productFormProvider(product).notifier).setBrand(result.id);
    }
  }

  Future<void> _openSupplierForm(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Supplier>(
      context: context,
      builder: (context) => const Dialog(child: SupplierForm(isDialog: true)),
    );
    if (result != null && result.id != null) {
      ref.read(productFormProvider(product).notifier).setSupplier(result.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productFormProvider(product);

    final selectedDepartment = ref.watch(
      provider.select((s) => s.departmentId),
    );
    final selectedCategory = ref.watch(provider.select((s) => s.categoryId));
    final selectedBrand = ref.watch(provider.select((s) => s.brandId));
    final selectedSupplier = ref.watch(provider.select((s) => s.supplierId));

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
            decoration: InputDecoration(
              labelText: 'Departamento',
              prefixIcon: const Icon(Icons.business_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Agregar Departamento',
                onPressed: () => _openDepartmentForm(context, ref),
              ),
            ),
            items: departments
                .map(
                  (dept) =>
                      DropdownMenuItem(value: dept.id, child: Text(dept.name)),
                )
                .toList(),
            onChanged: (value) =>
                ref.read(provider.notifier).setDepartment(value),
            validator: (value) => value == null ? 'Requerido' : null,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        categoriesAsync.when(
          data: (categories) {
            return DropdownButtonFormField<int>(
              initialValue: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Categoría',
                prefixIcon: const Icon(Icons.category_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Agregar Categoría',
                  onPressed: () => _openCategoryForm(context, ref),
                ),
              ),
              items: categories
                  .map(
                    (cat) =>
                        DropdownMenuItem(value: cat.id, child: Text(cat.name)),
                  )
                  .toList(),
              onChanged: (value) =>
                  ref.read(provider.notifier).setCategory(value),
              validator: (value) => value == null ? 'Requerido' : null,
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        brandsAsync.when(
          data: (brands) => DropdownButtonFormField<int>(
            initialValue: selectedBrand,
            decoration: InputDecoration(
              labelText: 'Marca (Opcional)',
              prefixIcon: const Icon(Icons.branding_watermark_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Agregar Marca',
                onPressed: () => _openBrandForm(context, ref),
              ),
            ),
            items: brands
                .map(
                  (brand) => DropdownMenuItem(
                    value: brand.id,
                    child: Text(brand.name),
                  ),
                )
                .toList(),
            onChanged: (value) => ref.read(provider.notifier).setBrand(value),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        suppliersAsync.when(
          data: (suppliers) => DropdownButtonFormField<int>(
            initialValue: selectedSupplier,
            decoration: InputDecoration(
              labelText: 'Proveedor (Opcional)',
              prefixIcon: const Icon(Icons.local_shipping_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Agregar Proveedor',
                onPressed: () => _openSupplierForm(context, ref),
              ),
            ),
            items: suppliers
                .map(
                  (supplier) => DropdownMenuItem(
                    value: supplier.id,
                    child: Text(supplier.name),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                ref.read(provider.notifier).setSupplier(value),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }
}
