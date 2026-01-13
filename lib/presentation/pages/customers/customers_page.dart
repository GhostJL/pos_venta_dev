import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/customer_providers.dart';
import 'package:posventa/presentation/providers/paginated_customers_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';
import 'package:posventa/presentation/mixins/search_debounce_mixin.dart';
import 'package:flutter/services.dart';

import 'package:posventa/presentation/widgets/customers/customer_card.dart';
import 'package:posventa/presentation/widgets/customers/customer_table_row.dart';
import 'package:posventa/presentation/widgets/common/empty_state_widget.dart';
import 'package:posventa/presentation/widgets/customers/debtors_tab.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  CustomersPageState createState() => CustomersPageState();
}

class CustomersPageState extends ConsumerState<CustomersPage>
    with PageLifecycleMixin, SearchDebounceMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  List<dynamic> get providersToInvalidate => [paginatedCustomersCountProvider];

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

  void _navigateToForm([Customer? customer]) {
    context.push('/customers/form', extra: customer);
  }

  void _onSearchChanged(String value) {
    debounceSearch(
      () => ref.read(customerSearchQueryProvider.notifier).setQuery(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.customerManage),
    );
    final countAsync = ref.watch(paginatedCustomersCountProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return DefaultTabController(
      length: 2,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
            if (hasManagePermission) _navigateToForm();
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
            title: const Text('Gestión de Clientes'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(
                120,
              ), // Height for TabBar + Search
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Directorio'),
                      Tab(text: 'Cuentas por Cobrar'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Buscar clientes...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withAlpha(100),
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
                ],
              ),
            ),
            actions: [
              // Filter Button
              Consumer(
                builder: (context, ref, _) {
                  final showInactive = ref.watch(customerShowInactiveProvider);
                  return IconButton(
                    icon: Icon(
                      showInactive
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    tooltip: showInactive
                        ? 'Ocultar Inactivos'
                        : 'Ver Inactivos',
                    onPressed: () {
                      ref.read(customerShowInactiveProvider.notifier).toggle();
                    },
                  );
                },
              ),
            ],
          ),
          body: TabBarView(
            children: [
              // Tab 1: Directory
              AsyncValueHandler<int>(
                value: countAsync,
                data: (count) {
                  if (count == 0) {
                    return const EmptyStateWidget(
                      icon: Icons.person_off_rounded,
                      message: 'No se encontraron clientes',
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 800;

                      return Column(
                        children: [
                          if (isDesktop) const CustomerHeader(),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: count,
                              itemBuilder: (context, index) {
                                final pageIndex = index ~/ kCustomerPageSize;
                                final indexInPage = index % kCustomerPageSize;

                                final pageAsync = ref.watch(
                                  paginatedCustomersPageProvider(
                                    pageIndex: pageIndex,
                                  ),
                                );

                                return pageAsync.when(
                                  data: (customers) {
                                    if (indexInPage >= customers.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final customer = customers[indexInPage];

                                    if (isDesktop) {
                                      return CustomerTableRow(
                                        customer: customer,
                                        hasManagePermission:
                                            hasManagePermission,
                                        onEdit: () => _navigateToForm(customer),
                                        onDelete: () => _confirmDelete(
                                          context,
                                          ref,
                                          customer,
                                        ),
                                        onTap: () => context.push(
                                          '/customers/${customer.id}',
                                        ),
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          CustomerCard(
                                            customer: customer,
                                            hasManagePermission:
                                                hasManagePermission,
                                            onEdit: () =>
                                                _navigateToForm(customer),
                                            onDelete: () => _confirmDelete(
                                              context,
                                              ref,
                                              customer,
                                            ),
                                            onTap: () => context.push(
                                              '/customers/${customer.id}',
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
                  icon: Icons.person_off_rounded,
                  message: 'No se encontraron clientes',
                ),
              ),

              // Tab 2: Debtors
              const DebtorsTab(),
            ],
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
                        label: const Text('Nuevo Cliente'),
                      )
                    : null),
        ),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, Customer customer) {
    ConfirmDeleteDialog.show(
      context: context,
      itemName: customer.fullName,
      itemType: 'el cliente',
      onConfirm: () async {
        await ref.read(customerProvider.notifier).deleteCustomer(customer.id!);
        // Reactive refresh
        ref.invalidate(paginatedCustomersPageProvider);
        ref.invalidate(paginatedCustomersCountProvider);
      },
      successMessage: 'Cliente eliminado correctamente',
    );
  }
}
