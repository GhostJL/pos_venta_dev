import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:posventa/presentation/widgets/products/lists/product_list_tile.dart'; // Import Tile
import 'package:posventa/presentation/widgets/products/lists/product_list_skeleton.dart'; // Import Skeleton
import 'package:posventa/presentation/widgets/products/search/product_search_bar.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';

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

    final isSmallScreen = MediaQuery.of(context).size.width < 1200;
    final isDesktop = !isSmallScreen;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (hasManagePermission) context.push('/products/new');
        },
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          // Future implementation
        },
      },
      child: Scaffold(
        appBar: AppBar(
          leading: isSmallScreen
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    MainLayout.scaffoldKey.currentState?.openDrawer();
                  },
                )
              : null,
          title: countAsync.when(
            data: (count) => Text('Productos ($count)'),
            loading: () => const Text('Productos'),
            error: (_, __) => const Text('Productos'),
          ),
          centerTitle: true,
          scrolledUnderElevation: 0,
          actions: [
            if (isDesktop) ...[
              FilledButton.icon(
                onPressed: () {
                  context.push('/products/new');
                },
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Producto'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/products/import_csv'),
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar'),
              ),
            ] else ...[
              IconButton(
                onPressed: () => context.push('/products/import_csv'),
                icon: const Icon(Icons.upload_file),
                tooltip: 'Importar CSV',
              ),
              IconButton(
                onPressed: () => context.push('/products/new'),
                icon: const Icon(Icons.add),
                tooltip: 'Nuevo Producto',
              ),
            ],
            const SizedBox(width: 8),
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
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              // Use 600 as breakpoint for Table vs Card List
                              final isDesktop = width > 700;

                              return Column(
                                children: [
                                  if (isDesktop) _buildDesktopHeader(context),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      // itemExtent improves scroll performance by skipping layout for off-screen items
                                      itemExtent: isDesktop ? 64.0 : null,
                                      itemCount: count,
                                      itemBuilder: (context, index) =>
                                          _buildItemAtIndex(
                                            index,
                                            count,
                                            isDesktop,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
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
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 48 + 16), // Image + Gap
          Expanded(flex: 3, child: Text('NOMBRE / CÓDIGO', style: textStyle)),
          if (MediaQuery.of(context).size.width > 1100)
            Expanded(flex: 2, child: Text('DEPARTAMENTO', style: textStyle)),
          Expanded(flex: 2, child: Text('PRECIO', style: textStyle)),
          // Make Stock header check for config?
          // Technically providers decide this, but for layout we assume space is reserved if needed.
          // Tile uses `if (useInventory)`, but we don't have access to settings here easily without ref reading again.
          // However, if we preserve alignment, it's safer to show header or empty.
          // Let's assume most use inventory or better to just show 'STOCK'
          Expanded(flex: 2, child: Text('STOCK', style: textStyle)),
          const SizedBox(width: 48), // Actions
        ],
      ),
    );
  }

  Widget _buildItemAtIndex(int index, int count, bool isDesktop) {
    final pageIndex = index ~/ kProductPageSize;
    final indexInPage = index % kProductPageSize;

    final pageAsync = ref.watch(
      paginatedProductsPageProvider(pageIndex: pageIndex),
    );

    return pageAsync.when(
      data: (products) {
        if (indexInPage >= products.length) return const SizedBox.shrink();
        final product = products[indexInPage];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0), // Smaller gap for list
          child: isDesktop
              ? _buildDesktopItem(context, product)
              : _buildMobileItem(context, product),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ProductListSkeleton(isDesktop: isDesktop),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDesktopItem(BuildContext context, Product product) {
    return ProductListTile(
      product: product,
      onTap: () => _showActions(context, product),
      onMorePressed: () => _showActions(context, product),
    );
  }

  Widget _buildMobileItem(BuildContext context, Product product) {
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
