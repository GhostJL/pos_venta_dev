import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/core/constants/ui_constants.dart';

class ProductFilterSheet extends ConsumerStatefulWidget {
  final int? departmentFilter;
  final int? categoryFilter;
  final int? brandFilter;
  final int? supplierFilter;
  final String sortOrder;
  final Function(int?) onDepartmentChanged;
  final Function(int?) onCategoryChanged;
  final Function(int?) onBrandChanged;
  final Function(int?) onSupplierChanged;
  final Function(String) onSortOrderChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onApplyFilters;

  const ProductFilterSheet({
    super.key,
    required this.departmentFilter,
    required this.categoryFilter,
    required this.brandFilter,
    required this.supplierFilter,
    required this.sortOrder,
    required this.onDepartmentChanged,
    required this.onCategoryChanged,
    required this.onBrandChanged,
    required this.onSupplierChanged,
    required this.onSortOrderChanged,
    required this.onClearFilters,
    required this.onApplyFilters,
  });

  @override
  ConsumerState<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends ConsumerState<ProductFilterSheet> {
  late int? _departmentFilter;
  late int? _categoryFilter;
  late int? _brandFilter;
  late int? _supplierFilter;
  late String _sortOrder;

  @override
  void initState() {
    super.initState();
    _departmentFilter = widget.departmentFilter;
    _categoryFilter = widget.categoryFilter;
    _brandFilter = widget.brandFilter;
    _supplierFilter = widget.supplierFilter;
    _sortOrder = widget.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    final departments = ref.watch(departmentListProvider);
    final categories = ref.watch(categoryListProvider);
    final brands = ref.watch(brandListProvider);
    final suppliers = ref.watch(supplierListProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          UIConstants.paddingLarge,
          0,
          UIConstants.paddingLarge,
          UIConstants.paddingLarge + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterDropdowns(departments, categories, brands, suppliers),
            const SizedBox(height: 24),
            _buildSortDropdown(),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdowns(
    AsyncValue departments,
    AsyncValue categories,
    AsyncValue brands,
    AsyncValue suppliers,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Filtrar y ordenar',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12),
        departments.when(
          data: (data) => _buildFilterDropdown(
            data,
            'Departamento',
            _departmentFilter,
            (val) => setState(() => _departmentFilter = val),
            Icons.business_rounded,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        categories.when(
          data: (data) => _buildFilterDropdown(
            data,
            'Categoría',
            _categoryFilter,
            (val) => setState(() => _categoryFilter = val),
            Icons.category_rounded,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        brands.when(
          data: (data) => _buildFilterDropdown(
            data,
            'Marca',
            _brandFilter,
            (val) => setState(() => _brandFilter = val),
            Icons.branding_watermark_rounded,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 16),
        suppliers.when(
          data: (data) => _buildFilterDropdown(
            data,
            'Proveedor',
            _supplierFilter,
            (val) => setState(() => _supplierFilter = val),
            Icons.local_shipping_rounded,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    List<dynamic> items,
    String label,
    int? currentValue,
    void Function(int?) onChanged,
    IconData icon,
  ) {
    return DropdownButtonFormField<int>(
      initialValue: currentValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e.id as int,
              child: Text(e.name as String),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _sortOrder,
      decoration: InputDecoration(
        labelText: 'Ordenar por',
        prefixIcon: const Icon(Icons.sort_rounded, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: 'name', child: Text('Nombre')),
        DropdownMenuItem(value: 'price', child: Text('Precio')),
        DropdownMenuItem(value: 'created_at', child: Text('Fecha')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _sortOrder = value);
        }
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              setState(() {
                _departmentFilter = null;
                _categoryFilter = null;
                _brandFilter = null;
                _supplierFilter = null;
              });
              widget.onClearFilters();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Limpiar todo'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: () {
              widget.onDepartmentChanged(_departmentFilter);
              widget.onCategoryChanged(_categoryFilter);
              widget.onBrandChanged(_brandFilter);
              widget.onSupplierChanged(_supplierFilter);
              widget.onSortOrderChanged(_sortOrder);
              widget.onApplyFilters();
              context.pop();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Aplicar filtros'),
          ),
        ),
      ],
    );
  }
}
