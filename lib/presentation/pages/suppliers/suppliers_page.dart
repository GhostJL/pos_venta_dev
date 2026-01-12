import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/providers/paginated_suppliers_provider.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';
import 'package:posventa/presentation/mixins/search_debounce_mixin.dart';
import 'package:flutter/services.dart';

import 'package:posventa/presentation/widgets/suppliers/supplier_card.dart';
import 'package:posventa/presentation/widgets/suppliers/supplier_table_row.dart';
import 'package:posventa/presentation/widgets/common/empty_state_widget.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  SuppliersPageState createState() => SuppliersPageState();
}

class SuppliersPageState extends ConsumerState<SuppliersPage>
    with PageLifecycleMixin, SearchDebounceMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  List<dynamic> get providersToInvalidate => [paginatedSuppliersCountProvider];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _showScrollToTop = false;

  void _onScroll() {
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

  void _navigateToForm([Supplier? supplier]) {
    context.push('/suppliers/form', extra: supplier);
  }

  void _onSearchChanged(String value) {
    debounceSearch(
      () => ref.read(supplierSearchQueryProvider.notifier).setQuery(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );
    final countAsync = ref.watch(paginatedSuppliersCountProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (hasManagePermission) _navigateToForm();
        },
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          // Focus search
        },
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          leading: isSmallScreen
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => MainLayout.of(context)?.openDrawer(),
                )
              : null,
          title: countAsync.when(
            data: (count) => Text(
              'Proveedores ($count)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => const Text('Proveedores'),
            error: (_, __) => const Text('Proveedores'),
          ),
          scrolledUnderElevation: 2,
          backgroundColor: colorScheme.surface,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar proveedores...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          actions: [
            Consumer(
              builder: (context, ref, _) {
                final showInactive = ref.watch(supplierShowInactiveProvider);
                return IconButton(
                  icon: Icon(
                    showInactive
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  tooltip: showInactive ? 'Ocultar Inactivos' : 'Ver Inactivos',
                  onPressed: () {
                    ref.read(supplierShowInactiveProvider.notifier).toggle();
                  },
                );
              },
            ),
          ],
        ),
        body: AsyncValueHandler<int>(
          value: countAsync,
          data: (count) {
            if (count == 0) {
              return const EmptyStateWidget(
                icon: Icons.business_rounded,
                message: 'No se encontraron proveedores',
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;

                return Column(
                  children: [
                    if (isDesktop) const SupplierHeader(),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: count,
                        itemBuilder: (context, index) {
                          final pageIndex = index ~/ kSupplierPageSize;
                          final indexInPage = index % kSupplierPageSize;

                          final pageAsync = ref.watch(
                            paginatedSuppliersPageProvider(
                              pageIndex: pageIndex,
                            ),
                          );

                          return pageAsync.when(
                            data: (suppliers) {
                              if (indexInPage >= suppliers.length) {
                                return const SizedBox.shrink();
                              }
                              final supplier = suppliers[indexInPage];

                              if (isDesktop) {
                                return SupplierTableRow(
                                  supplier: supplier,
                                  hasManagePermission: hasManagePermission,
                                  onEdit: () => _navigateToForm(supplier),
                                  onDelete: () =>
                                      _confirmDelete(context, ref, supplier),
                                );
                              } else {
                                return Column(
                                  children: [
                                    SupplierCard(
                                      supplier: supplier,
                                      hasManagePermission: hasManagePermission,
                                      onEdit: () => _navigateToForm(supplier),
                                      onDelete: () => _confirmDelete(
                                        context,
                                        ref,
                                        supplier,
                                      ),
                                    ),
                                    if (index < count - 1)
                                      const SizedBox(height: 12),
                                  ],
                                );
                              }
                            },
                            loading: () => _buildSkeletonItem(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
          emptyState: const EmptyStateWidget(
            icon: Icons.business_rounded,
            message: 'No se encontraron proveedores',
          ),
        ),
        floatingActionButton: _showScrollToTop
            ? FloatingActionButton(
                onPressed: _scrollToTop,
                mini: true,
                child: const Icon(Icons.arrow_upward),
              )
            : (hasManagePermission
                  ? FloatingActionButton.extended(
                      onPressed: () => _navigateToForm(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Nuevo Proveedor'),
                    )
                  : null),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Supplier supplier) {
    ConfirmDeleteDialog.show(
      context: context,
      itemName: supplier.name,
      itemType: 'el proveedor',
      onConfirm: () async {
        await ref
            .read(supplierListProvider.notifier)
            .deleteSupplier(supplier.id!);
        // Reactive refresh
        ref.invalidate(paginatedSuppliersPageProvider);
        ref.invalidate(paginatedSuppliersCountProvider);
      },
      successMessage: 'Proveedor eliminado correctamente',
    );
  }
}
