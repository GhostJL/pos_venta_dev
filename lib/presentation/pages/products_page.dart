import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/product_filter_sheet.dart';
import 'package:posventa/presentation/widgets/product_list_item.dart';
import 'package:posventa/presentation/widgets/product_active_filters.dart';
import 'package:posventa/presentation/widgets/product_search_bar.dart';
import 'package:posventa/presentation/widgets/product_actions_sheet.dart';
import 'package:posventa/presentation/utils/product_filter_utils.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends ConsumerState<ProductsPage> {
  String _searchQuery = '';
  int? _departmentFilter;
  int? _categoryFilter;
  int? _brandFilter;
  int? _supplierFilter;
  String _sortOrder = 'name';
  final TextEditingController _searchController = TextEditingController();

  int get _activeFilterCount => ProductFilterUtils.countActiveFilters(
    departmentFilter: _departmentFilter,
    categoryFilter: _categoryFilter,
    brandFilter: _brandFilter,
    supplierFilter: _supplierFilter,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productNotifierProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            ProductSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              onScannerPressed: _openScanner,
            ),
            const SizedBox(height: 16),
            ProductActiveFilters(
              departmentFilter: _departmentFilter,
              categoryFilter: _categoryFilter,
              brandFilter: _brandFilter,
              supplierFilter: _supplierFilter,
              onDepartmentRemoved: (val) =>
                  setState(() => _departmentFilter = val),
              onCategoryRemoved: (val) => setState(() => _categoryFilter = val),
              onBrandRemoved: (val) => setState(() => _brandFilter = val),
              onSupplierRemoved: (val) => setState(() => _supplierFilter = val),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: products.when(
                data: (productList) => _buildProductList(productList),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: hasManagePermission
          ? FloatingActionButton(
              onPressed: () => context.push('/products/form'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Productos'),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text('Filtros ($_activeFilterCount)'),
            selected: _activeFilterCount > 0,
            onSelected: (selected) {
              if (selected) {
                _showFilterSheet();
              } else {
                _clearFilters();
              }
            },
            backgroundColor: AppTheme.inputBackground,
            selectedColor: AppTheme.primary.withAlpha(50),
            checkmarkColor: AppTheme.primary,
            labelStyle: TextStyle(
              color: _activeFilterCount > 0
                  ? AppTheme.primary
                  : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide.none,
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(List<Product> productList) {
    final filteredList = ProductFilterUtils.filterAndSort(
      products: productList,
      searchQuery: _searchQuery,
      departmentFilter: _departmentFilter,
      categoryFilter: _categoryFilter,
      brandFilter: _brandFilter,
      supplierFilter: _supplierFilter,
      sortOrder: _sortOrder,
    );

    if (filteredList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = filteredList[index];
        return ProductListItem(
          product: product,
          onMorePressed: () => _showActionsSheet(product),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.textSecondary.withAlpha(100),
          ),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron productos',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _openScanner() async {
    final result = await context.push<String>('/scanner');

    if (result != null && mounted) {
      setState(() {
        _searchController.text = result;
        _searchQuery = result;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _departmentFilter = null;
      _categoryFilter = null;
      _brandFilter = null;
      _supplierFilter = null;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ProductFilterSheet(
        departmentFilter: _departmentFilter,
        categoryFilter: _categoryFilter,
        brandFilter: _brandFilter,
        supplierFilter: _supplierFilter,
        sortOrder: _sortOrder,
        onDepartmentChanged: (val) => _departmentFilter = val,
        onCategoryChanged: (val) => _categoryFilter = val,
        onBrandChanged: (val) => _brandFilter = val,
        onSupplierChanged: (val) => _supplierFilter = val,
        onSortOrderChanged: (val) => _sortOrder = val,
        onClearFilters: _clearFilters,
        onApplyFilters: () => setState(() {}),
      ),
    );
  }

  void _showActionsSheet(product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ProductActionsSheet(product: product),
    );
  }
}
