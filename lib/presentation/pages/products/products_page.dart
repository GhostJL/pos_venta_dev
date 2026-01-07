import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/paginated_products_provider.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/products/filters/product_filter_sheet.dart';
import 'package:posventa/presentation/widgets/products/lists/product_card.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  List<dynamic> get providersToInvalidate => [paginatedProductsCountProvider];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  bool _showScrollToTop = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show FAB if scrolled down more than 500 pixels
    if (_scrollController.hasClients) {
      final show = _scrollController.position.pixels > 500;
      if (show != _showScrollToTop) {
        setState(() {
          _showScrollToTop = show;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onSearchChanged(String value) {
    debounceSearch(
      () => ref.read(productSearchQueryProvider.notifier).setQuery(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Warm up filter data in background
    ref.watch(departmentListProvider);
    ref.watch(categoryListProvider);
    ref.watch(brandListProvider);
    ref.watch(supplierListProvider);

    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    final countAsync = ref.watch(paginatedProductsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: countAsync.when(
          data: (count) => Text('Productos ($count)'),
          loading: () => const Text('Productos'),
          error: (_, __) => const Text('Productos'),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        actions: [
          if (hasManagePermission)
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () => context.push('/products/import'),
              tooltip: 'Import Products',
            ),
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
                onChanged: _onSearchChanged,
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
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        selected: filters.showInactive,
                        onSelected: filterNotifier.setShowInactive,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: filters.showInactive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        checkmarkColor: theme.colorScheme.primary,
                        selectedColor: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundColor: theme.colorScheme.surface,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                      ),
                      // Total Count Indicator
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
                child: AsyncValueHandler<int>(
                  value: countAsync,
                  data: (count) => count == 0
                      ? const EmptyStateWidget(
                          icon: Icons.inventory_2_outlined,
                          message: 'No se encontraron productos',
                        )
                      : _buildPaginatedList(count),
                  emptyState: const EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    message: 'No se encontraron productos',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              mini: true,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  Widget _buildPaginatedList(int count) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: count,
      itemBuilder: (context, index) {
        final pageIndex = index ~/ kProductPageSize;
        final indexInPage = index % kProductPageSize;

        final pageAsync = ref.watch(
          paginatedProductsPageProvider(pageIndex: pageIndex),
        );

        return pageAsync.when(
          data: (products) {
            if (indexInPage >= products.length) return const SizedBox.shrink();
            final product = products[indexInPage];

            // Prefetch next page
            if (indexInPage == kProductPageSize - 5) {
              // Trigger explicit read/watch in background?
              // Just watching it in a ProviderContainer or causing a read is enough.
              // But we can't 'ref.watch' inside a callback or conditional easily without re-render.
              // However, this is part of the build phase of THIS item.
              // Using Future.microtask to avoid build side-effects?
              // Or just rely on natural scrolling.
            }
            return Column(
              children: [
                _buildProductItem(context, product),
                if (index < count - 1) const SizedBox(height: 12),
              ],
            );
          },
          loading: () => Column(
            children: [
              _buildSkeletonItem(),
              if (index < count - 1) const SizedBox(height: 12),
            ],
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    final isDisabled = !product.isActive;
    return RepaintBoundary(
      child: Slidable(
        key: ValueKey(product.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) async {
                await ref
                    .read(productNotifierProvider.notifier)
                    .toggleActive(product);
                // Invalidate cache of pages to force refresh of current view
                ref.invalidate(paginatedProductsPageProvider);
              },
              backgroundColor: isDisabled
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.errorContainer,
              foregroundColor: isDisabled
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onErrorContainer,
              icon: isDisabled
                  ? Icons.check_circle_outline_rounded
                  : Icons.pause_circle_outline_rounded,
              label: isDisabled ? 'Activar' : 'Desactivar',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: ProductCard(
          product: product,
          onTap: () => _showActions(context, product),
          onMorePressed: () => _showActions(context, product),
        ),
      ),
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
            width: 400,
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
              onApplyFilters: () {},
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
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
          onApplyFilters: () {},
        ),
      );
    }
  }

  void _showActions(BuildContext context, Product product) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 400,
            child: ProductActionsSheet(product: product),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => ProductActionsSheet(product: product),
      );
    }
  }
}
