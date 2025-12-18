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
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/providers/product_filters.dart';
import 'package:posventa/presentation/widgets/products/filters/chip_filter_widget.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/widgets/common/empty_state_widget.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';
import 'package:posventa/presentation/mixins/search_debounce_mixin.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends ConsumerState<ProductsPage>
    with PageLifecycleMixin, SearchDebounceMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  List<dynamic> get providersToInvalidate => [productNotifierProvider];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Warm up filter data in background
    ref.watch(departmentListProvider);
    ref.watch(categoryListProvider);
    ref.watch(brandListProvider);
    ref.watch(supplierListProvider);

    final products = ref.watch(productNotifierProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        centerTitle: true,
        scrolledUnderElevation: 0,
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
                  debounceSearch(
                    () => ref
                        .read(productSearchQueryProvider.notifier)
                        .setQuery(value),
                  );
                },
                onScannerPressed: _openScanner,
              ),
              const SizedBox(height: 4),

              Consumer(
                builder: (context, ref, child) {
                  final filters = ref.watch(productFiltersProvider);
                  final filterNotifier = ref.read(
                    productFiltersProvider.notifier,
                  );
                  final activeFilterCount = filters.activeFilterCount;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilterChip(
                        label: Text(
                          'Ver Inactivos',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: filters.showInactive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: filters.showInactive
                                ? theme.colorScheme.primary
                                : Colors.grey[700],
                          ),
                        ),
                        selected: filters.showInactive,
                        onSelected: filterNotifier.setShowInactive,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: filters.showInactive
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
                        label: 'Filtros ($activeFilterCount)',
                        activeFilterCount: activeFilterCount,
                        onSelected: () {
                          if (activeFilterCount > 0) {
                            filterNotifier.clearAll();
                          } else {
                            _showFilterSheet();
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),

              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final productsAsync = ref.watch(filteredProductsProvider);
                    return AsyncValueHandler<List<Product>>(
                      value: productsAsync,
                      data: (productList) => _buildProductList(productList),
                      emptyState: const EmptyStateWidget(
                        icon: Icons.inventory_2_outlined,
                        message: 'No se encontraron productos',
                      ),
                    );
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
    return ListView.separated(
      itemCount: productList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = productList[index];
        return RepaintBoundary(
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
      _searchController.text = result;
      ref.read(productSearchQueryProvider.notifier).setQuery(result);
    }
  }

  void _clearFilters() {
    ref.read(productFiltersProvider.notifier).clearAll();
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
              onDepartmentChanged: (val) =>
                  ref.read(productFiltersProvider.notifier).setDepartment(val),
              onCategoryChanged: (val) =>
                  ref.read(productFiltersProvider.notifier).setCategory(val),
              onBrandChanged: (val) =>
                  ref.read(productFiltersProvider.notifier).setBrand(val),
              onSupplierChanged: (val) =>
                  ref.read(productFiltersProvider.notifier).setSupplier(val),
              onSortOrderChanged: (val) =>
                  ref.read(productFiltersProvider.notifier).setSortOrder(val),
              onClearFilters: _clearFilters,
              onApplyFilters: () {}, // Handled by Riverpod automatically
            ), // Reutilizamos el widget
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ProductFilterSheet(
          onDepartmentChanged: (val) =>
              ref.read(productFiltersProvider.notifier).setDepartment(val),
          onCategoryChanged: (val) =>
              ref.read(productFiltersProvider.notifier).setCategory(val),
          onBrandChanged: (val) =>
              ref.read(productFiltersProvider.notifier).setBrand(val),
          onSupplierChanged: (val) =>
              ref.read(productFiltersProvider.notifier).setSupplier(val),
          onSortOrderChanged: (val) =>
              ref.read(productFiltersProvider.notifier).setSortOrder(val),
          onClearFilters: _clearFilters,
          onApplyFilters: () {}, // Handled by Riverpod automatically
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
