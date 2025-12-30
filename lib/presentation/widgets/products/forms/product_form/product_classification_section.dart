import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/domain/entities/category.dart';
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
import 'package:posventa/presentation/widgets/common/selection_sheet.dart';

class ProductClassificationSection extends ConsumerWidget {
  final Product? product;

  const ProductClassificationSection({super.key, this.product});

  // Helper to open generic selection sheet
  Future<void> _showSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) labelBuilder,
    T? selectedItem,
    required ValueChanged<T?> onSelected,
    VoidCallback? onAdd, // Added
  }) async {
    final result = await showModalBottomSheet<SelectionSheetResult<T>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SelectionSheet<T>(
        title: title,
        items: items,
        itemLabelBuilder: labelBuilder,
        selectedItem: selectedItem,
        areEqual: (a, b) => labelBuilder(a) == labelBuilder(b),
        onAdd: onAdd, // Pass to sheet
      ),
    );

    if (result != null) {
      if (result.isCleared) {
        onSelected(null);
      } else if (result.value != null) {
        onSelected(result.value);
      }
    }
  }

  Future<void> _openDepartmentForm(BuildContext context, WidgetRef ref) async {
    final newId = await showDialog<int?>(
      context: context,
      builder: (context) => const DepartmentForm(isDialog: true),
    );
    if (newId != null) {
      ref.read(productFormProvider(product).notifier).setDepartment(newId);
    }
  }

  Future<void> _openCategoryForm(BuildContext context, WidgetRef ref) async {
    final newId = await showDialog<int?>(
      context: context,
      builder: (context) => const CategoryForm(isDialog: true),
    );
    if (newId != null) {
      ref.read(productFormProvider(product).notifier).setCategory(newId);
    }
  }

  Future<void> _openBrandForm(BuildContext context, WidgetRef ref) async {
    final newBrand = await showDialog<Brand?>(
      context: context,
      builder: (context) => const BrandForm(isDialog: true),
    );
    if (newBrand?.id != null) {
      ref.read(productFormProvider(product).notifier).setBrand(newBrand!.id!);
    }
  }

  Future<void> _openSupplierForm(BuildContext context, WidgetRef ref) async {
    final newSupplier = await showDialog<Supplier?>(
      context: context,
      builder: (context) => const SupplierForm(isDialog: true),
    );
    if (newSupplier?.id != null) {
      ref
          .read(productFormProvider(product).notifier)
          .setSupplier(newSupplier!.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productFormProvider(product);

    final selectedDepartmentId = ref.watch(
      provider.select((s) => s.departmentId),
    );
    final selectedCategoryId = ref.watch(provider.select((s) => s.categoryId));
    final selectedBrandId = ref.watch(provider.select((s) => s.brandId));
    final selectedSupplierId = ref.watch(provider.select((s) => s.supplierId));
    final showValidationErrors = ref.watch(
      provider.select((s) => s.showValidationErrors),
    );

    final departmentsAsync = ref.watch(departmentListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final brandsAsync = ref.watch(brandListProvider);
    final suppliersAsync = ref.watch(supplierListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DEPARTMENT
        departmentsAsync.when(
          data: (departments) {
            final selectedDept = departments.cast<Department?>().firstWhere(
              (d) => d?.id == selectedDepartmentId,
              orElse: () => null,
            );

            return SelectionField(
              label: 'Departamento',
              placeholder: 'Seleccionar departamento',
              value: selectedDept?.name,
              helperText: 'Agrupación general del producto (ej. Bebidas)',
              prefixIcon: Icons.business_rounded,
              // Removed custom suffixIcon to use default behavior (Clear or Arrow)
              onTap: () => _showSelectionSheet<Department>(
                context: context,
                title: 'Seleccionar Departamento',
                items: departments,
                labelBuilder: (d) => d.name,
                selectedItem: selectedDept,
                onSelected: (d) =>
                    ref.read(provider.notifier).setDepartment(d?.id),
                onAdd: () => _openDepartmentForm(context, ref),
              ),
              onClear: () => ref.read(provider.notifier).setDepartment(null),
              errorMessage:
                  (showValidationErrors && selectedDepartmentId == null)
                  ? 'Requerido'
                  : null,
            );
          },
          loading: () => const SelectionField(
            label: 'Departamento',
            onTap: _noOp,
            isLoading: true,
          ),
          error: (e, s) => Text('Error: $e'),
        ),

        const SizedBox(height: 16),

        // CATEGORY
        categoriesAsync.when(
          data: (categories) {
            final selectedCat = categories.cast<Category?>().firstWhere(
              (c) => c?.id == selectedCategoryId,
              orElse: () => null,
            );

            return SelectionField(
              label: 'Categoría',
              placeholder: 'Seleccionar categoría',
              value: selectedCat?.name,
              helperText: 'Clasificación específica (ej. Refrescos)',
              prefixIcon: Icons.category_rounded,
              onTap: () => _showSelectionSheet<Category>(
                context: context,
                title: 'Seleccionar Categoría',
                items: categories,
                labelBuilder: (c) => c.name,
                selectedItem: selectedCat,
                onSelected: (c) =>
                    ref.read(provider.notifier).setCategory(c?.id),
                onAdd: () => _openCategoryForm(context, ref),
              ),
              onClear: () => ref.read(provider.notifier).setCategory(null),
              errorMessage: (showValidationErrors && selectedCategoryId == null)
                  ? 'Requerido'
                  : null,
            );
          },
          loading: () => const SelectionField(
            label: 'Categoría',
            onTap: _noOp,
            isLoading: true,
          ),
          error: (e, s) => Text('Error: $e'),
        ),

        const SizedBox(height: 16),

        // BRAND
        brandsAsync.when(
          data: (brands) {
            final selectedBrand = brands.cast<Brand?>().firstWhere(
              (b) => b?.id == selectedBrandId,
              orElse: () => null,
            );

            return SelectionField(
              label: 'Marca (Opcional)',
              placeholder: 'Seleccionar marca',
              value: selectedBrand?.name,
              helperText: 'Fabricante del producto',
              prefixIcon: Icons.branding_watermark_rounded,
              onTap: () => _showSelectionSheet<Brand>(
                context: context,
                title: 'Seleccionar Marca',
                items: brands,
                labelBuilder: (b) => b.name,
                selectedItem: selectedBrand,
                onSelected: (b) => ref.read(provider.notifier).setBrand(b?.id),
                onAdd: () => _openBrandForm(context, ref),
              ),
              onClear: () => ref.read(provider.notifier).setBrand(null),
            );
          },
          loading: () => const SelectionField(
            label: 'Marca',
            onTap: _noOp,
            isLoading: true,
          ),
          error: (e, s) => Text('Error: $e'),
        ),

        const SizedBox(height: 16),

        // SUPPLIER
        suppliersAsync.when(
          data: (suppliers) {
            final selectedSupplier = suppliers.cast<Supplier?>().firstWhere(
              (s) => s?.id == selectedSupplierId,
              orElse: () => null,
            );

            return SelectionField(
              label: 'Proveedor (Opcional)',
              placeholder: 'Seleccionar proveedor',
              value: selectedSupplier?.name,
              helperText: 'Quién suministra este producto',
              prefixIcon: Icons.local_shipping_rounded,
              onTap: () => _showSelectionSheet<Supplier>(
                context: context,
                title: 'Seleccionar Proveedor',
                items: suppliers,
                labelBuilder: (s) => s.name,
                selectedItem: selectedSupplier,
                onSelected: (s) =>
                    ref.read(provider.notifier).setSupplier(s?.id),
                onAdd: () => _openSupplierForm(context, ref),
              ),
              onClear: () => ref.read(provider.notifier).setSupplier(null),
            );
          },
          loading: () => const SelectionField(
            label: 'Proveedor',
            onTap: _noOp,
            isLoading: true,
          ),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }
}

void _noOp() {}
