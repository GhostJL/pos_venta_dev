import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/presentation/providers/paginated_sales_provider.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/layouts/permission_denied_widget.dart';
import 'package:posventa/presentation/widgets/sales/history/sales_card_history_widget.dart';
import 'package:posventa/presentation/widgets/common/filters/date_range_filter.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/widgets/common/empty_state_widget.dart';

class SalesHistoryPage extends ConsumerStatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  ConsumerState<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends ConsumerState<SalesHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Set initial filter based on role
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        if (user.role == UserRole.cajero) {
          ref.read(saleFilterProvider.notifier).setCashierId(user.id);
        } else {
          ref.read(saleFilterProvider.notifier).setCashierId(null);
        }
      }
    });
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

  void _onDateRangeChanged(DateTime? start, DateTime? end) {
    ref.read(saleFilterProvider.notifier).setRange(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final hasViewPermission = ref.watch(
      hasPermissionProvider(PermissionConstants.reportsView),
    );

    // Only watch count
    final countAsync = ref.watch(paginatedSalesCountProvider);
    final filter = ref.watch(saleFilterProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    // Apply role-based filtering on build (or useEffect)
    // Using listen to auth state changes to update filter
    ref.listen(authProvider, (previous, next) {
      final user = next.user;
      if (user != null) {
        if (user.role == UserRole.cajero) {
          // If user is cashier, force filter by their ID
          // Use Future.microtask to avoid build-phase state updates
          Future.microtask(() {
            ref.read(saleFilterProvider.notifier).setCashierId(user.id);
          });
        } else {
          // Admin sees all
          Future.microtask(() {
            ref.read(saleFilterProvider.notifier).setCashierId(null);
          });
        }
      }
    });

    // Initial check (use a simple effect pattern)
    // We cant easily use useEffect without flutter_hooks, so we do a pragmatic check
    // or rely on the initState.
    // However, since we are in build, let's just ensure it's set if not already matched?
    // Doing strict "set on build" is risky for infinite loops.
    // Better strategy: Set it once in initState or rely on the listener above.
    // Let's rely on listener + one-time init.
    // But we need to act on the *current* auth state too.

    if (!hasViewPermission) {
      return PermissionDeniedWidget(
        message:
            'No puedes entrar a este módulo.\n\nContacta a un administrador para obtener acceso.',
        icon: Icons.assessment_outlined,
        backRoute: '/home',
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: isSmallScreen
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () =>
                    MainLayout.scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        title: countAsync.when(
          data: (count) => Text('Historial de Ventas ($count)'),
          loading: () => const Text('Historial de Ventas'),
          error: (_, __) => const Text('Historial de Ventas'),
        ),
        forceMaterialTransparency: true,
        actions: [
          DateRangeFilter(
            startDate: filter.start,
            endDate: filter.end,
            onDateRangeChanged: _onDateRangeChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              mini: true,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: AsyncValueHandler<int>(
        value: countAsync,
        data: (count) {
          if (count == 0) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              message: filter.start != null && filter.end != null
                  ? 'No hay ventas en este rango de fechas'
                  : 'No hay ventas registradas',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(paginatedSalesCountProvider);
              return Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: count,
              itemBuilder: (context, index) {
                final pageIndex = index ~/ kSalePageSize;
                final indexInPage = index % kSalePageSize;

                final pageAsync = ref.watch(
                  paginatedSalesPageProvider(pageIndex: pageIndex),
                );

                return pageAsync.when(
                  data: (sales) {
                    if (indexInPage >= sales.length) {
                      return const SizedBox.shrink();
                    }
                    final sale = sales[indexInPage];
                    return SaleCardHistoryWidget(sale: sale);
                  },
                  loading: () => _buildSkeletonItem(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          );
        },
        emptyState: const EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          message: 'No hay ventas registradas',
        ),
        onRetry: () => ref.invalidate(paginatedSalesCountProvider),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
