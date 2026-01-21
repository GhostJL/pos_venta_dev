import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/paginated_sales_provider.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/utils/platform_detector.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/widgets/common/empty_state_widget.dart';
import 'package:posventa/presentation/widgets/common/filters/date_range_filter.dart';
import 'package:posventa/presentation/widgets/common/layouts/permission_denied_widget.dart';
import 'package:posventa/presentation/widgets/sales/history/desktop/sale_card_desktop.dart';
import 'package:posventa/presentation/widgets/sales/history/mobile/sale_card_mobile.dart';
import 'package:posventa/presentation/widgets/sales/history/tablet/sale_card_tablet.dart';

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
    // Set initial filter based on role logic
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

    final countAsync = ref.watch(paginatedSalesCountProvider);
    final filter = ref.watch(saleFilterProvider);
    final isMobile = PlatformDetector.isMobile(context);

    // Apply role-based filtering logic listener
    ref.listen(authProvider, (previous, next) {
      final user = next.user;
      if (user != null) {
        if (user.role == UserRole.cajero) {
          Future.microtask(() {
            ref.read(saleFilterProvider.notifier).setCashierId(user.id);
          });
        } else {
          Future.microtask(() {
            ref.read(saleFilterProvider.notifier).setCashierId(null);
          });
        }
      }
    });

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
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => MainLayout.of(context)?.openDrawer(),
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
            child: Builder(
              builder: (context) {
                // Determine platform based on width using MediaQuery to avoid LayoutBuilder mutation issues
                final width = MediaQuery.of(context).size.width;
                DevicePlatform platform;
                if (width < 600) {
                  platform = DevicePlatform.mobile;
                } else if (width < 900) {
                  platform = DevicePlatform.tablet;
                } else {
                  platform = DevicePlatform.desktop;
                }

                // Unified ListView for all platforms
                return ListView.builder(
                  controller: _scrollController,
                  padding: platform == DevicePlatform.mobile
                      ? const EdgeInsets.all(16)
                      : const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                  cacheExtent: 500,
                  physics: const AlwaysScrollableScrollPhysics(),
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

                        return switch (platform) {
                          DevicePlatform.mobile => SaleCardMobile(sale: sale),
                          DevicePlatform.tablet => SaleCardTablet(sale: sale),
                          DevicePlatform.desktop => SaleCardDesktop(sale: sale),
                        };
                      },
                      loading: () => _buildSkeletonItem(platform),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
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

  Widget _buildSkeletonItem(DevicePlatform platform) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: platform == DevicePlatform.mobile ? 140 : 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
