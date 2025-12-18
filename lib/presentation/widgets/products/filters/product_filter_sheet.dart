import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';

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
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    final departments = ref.watch(departmentListProvider);
    final categories = ref.watch(categoryListProvider);
    final brands = ref.watch(brandListProvider);
    final suppliers = ref.watch(supplierListProvider);

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTablet) Center(child: _buildHandle(theme)),
            _buildHeader(theme),
            const Divider(height: 1, thickness: 0.5),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel(theme, 'Filtros de Catálogo'),
                    const SizedBox(height: 16),
                    _buildAsyncDropdown(
                      asyncValue: departments,
                      label: 'Departamento',
                      currentValue: _departmentFilter,
                      icon: Icons.business_outlined,
                      onChanged: (val) =>
                          setState(() => _departmentFilter = val),
                    ),
                    _buildAsyncDropdown(
                      asyncValue: categories,
                      label: 'Categoría',
                      currentValue: _categoryFilter,
                      icon: Icons.category_outlined,
                      onChanged: (val) => setState(() => _categoryFilter = val),
                    ),
                    _buildAsyncDropdown(
                      asyncValue: brands,
                      label: 'Marca',
                      currentValue: _brandFilter,
                      icon: Icons.branding_watermark_outlined,
                      onChanged: (val) => setState(() => _brandFilter = val),
                    ),
                    _buildAsyncDropdown(
                      asyncValue: suppliers,
                      label: 'Proveedor',
                      currentValue: _supplierFilter,
                      icon: Icons.local_shipping_outlined,
                      onChanged: (val) => setState(() => _supplierFilter = val),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionLabel(theme, 'Preferencias de Lista'),
                    const SizedBox(height: 16),
                    _buildSortSelector(theme),
                    const SizedBox(height: 32),
                    _buildFooterActions(context, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        fontSize: 11,
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filtrar productos',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncDropdown({
    required AsyncValue asyncValue,
    required String label,
    required int? currentValue,
    required IconData icon,
    required Function(int?) onChanged,
  }) {
    return asyncValue.when(
      data: (items) => _buildFlatDropdownField(
        items: items as List<dynamic>,
        label: label,
        currentValue: currentValue,
        icon: icon,
        onChanged: onChanged,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildFlatDropdownField({
    required List<dynamic> items,
    required String label,
    required int? currentValue,
    required IconData icon,
    required Function(int?) onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        initialValue: currentValue,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          labelText: label,
          labelStyle: TextStyle(fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
        items: [
          DropdownMenuItem<int>(
            value: null,
            child: Text('Todos los ${label}s'),
          ),
          ...items.map(
            (e) => DropdownMenuItem<int>(
              value: e.id as int,
              child: Text(e.name as String),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSortSelector(ThemeData theme) {
    return DropdownButtonFormField<String>(
      initialValue: _sortOrder,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.sort_rounded, size: 20),
        labelText: 'Ordenar por',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'name', child: Text('Nombre (A-Z)')),
        DropdownMenuItem(value: 'price', child: Text('Precio')),
        DropdownMenuItem(value: 'created_at', child: Text('Más recientes')),
      ],
      onChanged: (val) {
        if (val != null) setState(() => _sortOrder = val);
      },
    );
  }

  Widget _buildFooterActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _departmentFilter = null;
                _categoryFilter = null;
                _brandFilter = null;
                _supplierFilter = null;
              });
              widget.onClearFilters();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Limpiar',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
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
              elevation: 0,
            ),
            child: const Text(
              'Aplicar filtros',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
