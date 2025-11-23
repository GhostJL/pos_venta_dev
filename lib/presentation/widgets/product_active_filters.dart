import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';

class ProductActiveFilters extends ConsumerWidget {
  final int? departmentFilter;
  final int? categoryFilter;
  final int? brandFilter;
  final int? supplierFilter;
  final Function(int?) onDepartmentRemoved;
  final Function(int?) onCategoryRemoved;
  final Function(int?) onBrandRemoved;
  final Function(int?) onSupplierRemoved;

  const ProductActiveFilters({
    super.key,
    this.departmentFilter,
    this.categoryFilter,
    this.brandFilter,
    this.supplierFilter,
    required this.onDepartmentRemoved,
    required this.onCategoryRemoved,
    required this.onBrandRemoved,
    required this.onSupplierRemoved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(departmentListProvider);
    final categories = ref.watch(categoryListProvider);
    final brands = ref.watch(brandListProvider);
    final suppliers = ref.watch(supplierListProvider);

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        if (departmentFilter != null)
          departments.when(
            data: (list) {
              final name = list
                  .firstWhere((d) => d.id == departmentFilter)
                  .name;
              return _buildFilterChip(
                label: 'Dpto: $name',
                color: AppTheme.primary,
                onDeleted: () => onDepartmentRemoved(null),
              );
            },
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
        if (categoryFilter != null)
          categories.when(
            data: (list) {
              final name = list.firstWhere((c) => c.id == categoryFilter).name;
              return _buildFilterChip(
                label: 'Cat: $name',
                color: AppTheme.secondary,
                onDeleted: () => onCategoryRemoved(null),
              );
            },
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
        if (brandFilter != null)
          brands.when(
            data: (list) {
              final name = list.firstWhere((b) => b.id == brandFilter).name;
              return _buildFilterChip(
                label: 'Marca: $name',
                color: Colors.orange,
                onDeleted: () => onBrandRemoved(null),
              );
            },
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
        if (supplierFilter != null)
          suppliers.when(
            data: (list) {
              final name = list.firstWhere((s) => s.id == supplierFilter).name;
              return _buildFilterChip(
                label: 'Prov: $name',
                color: Colors.purple,
                onDeleted: () => onSupplierRemoved(null),
              );
            },
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required Color color,
    required VoidCallback onDeleted,
  }) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      backgroundColor: color.withAlpha(20),
      labelStyle: TextStyle(color: color, fontSize: 12),
      deleteIconColor: color,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
