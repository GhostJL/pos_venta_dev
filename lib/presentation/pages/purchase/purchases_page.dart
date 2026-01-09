import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/presentation/providers/paginated_purchases_provider.dart';
import 'package:posventa/presentation/providers/purchase_filter_chip_provider.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/purchases/filters/chips/purchase_filter_chips.dart';
import 'package:posventa/presentation/widgets/purchases/misc/empty_purchases_view.dart';
import 'package:posventa/presentation/widgets/purchases/lists/purchase_card_widget.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:flutter/services.dart';
import 'package:posventa/presentation/widgets/purchases/lists/purchase_table_row.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    // Only fetch count. Pages are fetched on demand.
    final countAsync = ref.watch(paginatedPurchasesCountProvider);

    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );
    final selectedFilter = ref.watch(purchaseFilterProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (hasManagePermission) context.push('/purchases/new');
        },
      },
      child: Scaffold(
        appBar: AppBar(
          leading: isSmallScreen
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () =>
                      MainLayout.scaffoldKey.currentState?.openDrawer(),
                )
              : null,
          title: countAsync.when(
            data: (count) => Text('Compras ($count)'),
            loading: () => const Text('Compras'),
            error: (_, __) => const Text('Compras'),
          ),
          forceMaterialTransparency: true,
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showScrollToTop)
              FloatingActionButton(
                heroTag: 'scrollToTop',
                onPressed: _scrollToTop,
                mini: true,
                child: const Icon(Icons.arrow_upward),
              ),
            if (_showScrollToTop) const SizedBox(height: 16),
            if (hasManagePermission)
              FloatingActionButton.extended(
                heroTag: 'newPurchase',
                onPressed: () => context.push('/purchases/new'),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Nueva Compra'),
                tooltip: 'Crear Nueva Compra',
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              PurchaseFilterChips(selectedFilter: selectedFilter),
              Expanded(
                child: AsyncValueHandler<int>(
                  value: countAsync,
                  data: (count) {
                    if (count == 0) {
                      return const EmptyPurchasesView();
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 800;

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(paginatedPurchasesCountProvider);
                            return Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount:
                                count + (isDesktop ? 1 : 0), // Header space
                            itemBuilder: (context, index) {
                              if (isDesktop && index == 0) {
                                return const PurchaseHeader();
                              }

                              final actualIndex = isDesktop ? index - 1 : index;

                              final pageIndex =
                                  actualIndex ~/ kPurchasePageSize;
                              final indexInPage =
                                  actualIndex % kPurchasePageSize;

                              final pageAsync = ref.watch(
                                paginatedPurchasesPageProvider(
                                  pageIndex: pageIndex,
                                ),
                              );

                              return pageAsync.when(
                                data: (purchases) {
                                  if (indexInPage >= purchases.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final purchase = purchases[indexInPage];
                                  if (isDesktop) {
                                    return PurchaseTableRow(purchase: purchase);
                                  }
                                  return PurchaseCard(purchase: purchase);
                                },
                                loading: () => _buildSkeletonItem(),
                                error: (_, __) => const SizedBox.shrink(),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  emptyState: const EmptyPurchasesView(),
                  onRetry: () =>
                      ref.invalidate(paginatedPurchasesCountProvider),
                ),
              ),
            ],
          ),
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
}
