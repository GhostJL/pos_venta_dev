import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/products/filters/product_filter_sheet.dart';
import 'package:posventa/presentation/widgets/products/lists/product_list_item.dart';
import 'package:posventa/presentation/widgets/products/search/product_search_bar.dart';
import 'package:posventa/presentation/widgets/products/actions/product_actions_sheet.dart';
import 'package:posventa/core/utils/product_filter_utils.dart';
import 'package:posventa/presentation/widgets/common/empty_state_widget.dart';
import 'package:posventa/presentation/widgets/products/filters/chip_filter_widget.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';
import 'package:posventa/presentation/mixins/search_debounce_mixin.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends ConsumerState<ProductsPage>
    with PageLifecycleMixin, SearchDebounceMixin {
  String _searchQuery = '';
  int? _departmentFilter;
  int? _categoryFilter;
  int? _brandFilter;
  int? _supplierFilter;
  String _sortOrder = 'name';
  final TextEditingController _searchController = TextEditingController();

  @override
  List<dynamic> get providersToInvalidate => [productNotifierProvider];
  // 1. Añade esta variable al inicio del estado
  bool _showInactive = false;

  // 2. Actualiza el conteo de filtros para incluir el estado de inactivos
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
    final theme = Theme.of(context);
    final products = ref.watch(productNotifierProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Productos'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        actions: [
          if (hasManagePermission)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.push('/products/form'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              ProductSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  debounceSearch(() => setState(() => _searchQuery = value));
                },
                onScannerPressed: _openScanner,
              ),
              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Cambiado para separar los elementos
                children: [
                  // Nuevo Chip para alternar inactivos
                  FilterChip(
                    label: Text(
                      'Ver Inactivos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _showInactive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _showInactive
                            ? theme.colorScheme.primary
                            : Colors.grey[700],
                      ),
                    ),
                    selected: _showInactive,
                    onSelected: (value) =>
                        setState(() => _showInactive = value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _showInactive
                            ? theme.colorScheme.primary
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    checkmarkColor: theme.colorScheme.primary,
                    selectedColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    backgroundColor: Colors.white,
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                  ),

                  ChipFilterWidget(
                    label: 'Filtros ($_activeFilterCount)',
                    activeFilterCount: _activeFilterCount,
                    onSelected: () {
                      if (_activeFilterCount > 0) {
                        _clearFilters();
                      } else {
                        _showFilterSheet();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Expanded(
                child: AsyncValueHandler<List<Product>>(
                  value: products,
                  data: (productList) => _buildProductList(productList),
                  emptyState: const EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    message: 'No se encontraron productos',
                  ),
                  isEmpty: (productList) {
                    final filteredList = ProductFilterUtils.filterAndSort(
                      products: productList,
                      searchQuery: _searchQuery,
                      departmentFilter: _departmentFilter,
                      categoryFilter: _categoryFilter,
                      brandFilter: _brandFilter,
                      supplierFilter: _supplierFilter,
                      sortOrder: _sortOrder,
                    );
                    return filteredList.isEmpty;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> productList) {
    // Primero aplicamos el filtro de activo/inactivo manualmente si la utilidad no lo tiene
    final baseList = productList.where((p) {
      if (_showInactive) {
        return true; // Si queremos ver inactivos, mostramos todos
      }
      return p.isActive; // Si no, solo los activos
    }).toList();

    final filteredList = ProductFilterUtils.filterAndSort(
      products: baseList, // Usamos la lista filtrada por estado
      searchQuery: _searchQuery,
      departmentFilter: _departmentFilter,
      categoryFilter: _categoryFilter,
      brandFilter: _brandFilter,
      supplierFilter: _supplierFilter,
      sortOrder: _sortOrder,
    );

    return ListView.separated(
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = filteredList[index];
        // Opcional: Podrías envolver el item en un Opacity si está inactivo
        return Opacity(
          opacity: product.isActive ? 1.0 : 0.6,
          child: ProductListItem(
            product: product,
            onMorePressed: () => _showActions(context, product),
          ),
        );
      },
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
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 400, // Ancho fijo para que no se estire
            child: ProductFilterSheet(
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
            ), // Reutilizamos el widget
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
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
  }

  void _showActions(BuildContext context, Product product) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet) {
      // Diseño para Tablet: Un diálogo compacto y centrado (o lateral)
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 400, // Ancho fijo para que no se estire
            child: ProductActionsSheet(
              product: product,
            ), // Reutilizamos el widget
          ),
        ),
      );
    } else {
      // Diseño para Móvil: El sheet que ya tenemos
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ProductActionsSheet(product: product),
      );
    }
  }
}
