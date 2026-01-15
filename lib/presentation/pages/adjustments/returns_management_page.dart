import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:posventa/presentation/widgets/common/filters/date_range_filter.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/widgets/common/empty_state_widget.dart';
import 'package:posventa/presentation/widgets/sales/returns/detail/sale_return_card.dart';

// Local provider for the date filter state on this page
final returnsDateRangeProvider = StateProvider.autoDispose<DateTimeRange?>(
  (ref) => null,
);

class ReturnsManagementPage extends ConsumerStatefulWidget {
  const ReturnsManagementPage({super.key});

  @override
  ConsumerState<ReturnsManagementPage> createState() =>
      _ReturnsManagementPageState();
}

class _ReturnsManagementPageState extends ConsumerState<ReturnsManagementPage> {
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
    // 1. Watch Date Range
    final dateRange = ref.watch(returnsDateRangeProvider);

    // 2. Watch Data (filtered by range)
    final returnsAsync = ref.watch(
      filteredSaleReturnsStreamProvider(dateRange),
    );

    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      appBar: AppBar(
        leading: isSmallScreen
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => MainLayout.of(context)?.openDrawer(),
              )
            : null,
        title: const Text('Historial de Devoluciones'),
        forceMaterialTransparency: true,
        actions: [
          // Date Filter
          DateRangeFilter(
            startDate: dateRange?.start,
            endDate: dateRange?.end,
            onDateRangeChanged: (start, end) {
              if (start != null && end != null) {
                ref.read(returnsDateRangeProvider.notifier).state =
                    DateTimeRange(start: start, end: end);
              } else {
                ref.read(returnsDateRangeProvider.notifier).state = null;
              }
            },
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
      body: AsyncValueHandler<List<SaleReturn>>(
        value: returnsAsync,
        data: (returns) {
          if (returns.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.assignment_return_outlined,
              message: dateRange != null
                  ? 'No hay devoluciones en este rango de fechas'
                  : 'No hay devoluciones registradas',
            );
          }

          // Responsive Layout
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              if (isWide) {
                // Desktop: Grid
                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 450, // Slightly wider than sales card
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 280, // Height of the card
                  ),
                  itemCount: returns.length,
                  itemBuilder: (context, index) {
                    final item = returns[index];
                    return SaleReturnCard(returnItem: item);
                  },
                );
              } else {
                // Mobile: List
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: returns.length,
                  itemBuilder: (context, index) {
                    final item = returns[index];
                    return SaleReturnCard(returnItem: item);
                  },
                );
              }
            },
          );
        },
        emptyState: const EmptyStateWidget(
          icon: Icons.assignment_return_outlined,
          message: 'No hay devoluciones registradas',
        ),
        onRetry: () =>
            ref.invalidate(filteredSaleReturnsStreamProvider(dateRange)),
      ),
    );
  }
}
