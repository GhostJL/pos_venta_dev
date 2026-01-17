import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/report_models.dart';
import 'package:posventa/presentation/providers/di/reports_di.dart';

part 'reports_provider.g.dart';

class ReportsState {
  final bool isLoading;
  final List<SalesSummary> dailySales;
  final List<ProductPerformance> topProducts;
  final ZReport? zReport;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, double> paymentBreakdown;
  final double inventoryValue;
  final List<LowStockItem> lowStockItems;

  const ReportsState({
    this.isLoading = false,
    this.dailySales = const [],
    this.topProducts = const [],
    this.zReport,
    required this.startDate,
    required this.endDate,
    this.paymentBreakdown = const {},
    this.inventoryValue = 0.0,
    this.lowStockItems = const [],
  });

  ReportsState copyWith({
    bool? isLoading,
    List<SalesSummary>? dailySales,
    List<ProductPerformance>? topProducts,
    ZReport? zReport,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, double>? paymentBreakdown,
    double? inventoryValue,
    List<LowStockItem>? lowStockItems,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      dailySales: dailySales ?? this.dailySales,
      topProducts: topProducts ?? this.topProducts,
      zReport: zReport ?? this.zReport,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentBreakdown: paymentBreakdown ?? this.paymentBreakdown,
      inventoryValue: inventoryValue ?? this.inventoryValue,
      lowStockItems: lowStockItems ?? this.lowStockItems,
    );
  }
}

@riverpod
class ReportsNotifier extends _$ReportsNotifier {
  @override
  ReportsState build() {
    return ReportsState(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(reportsRepositoryProvider);

      final sales = await repo.getDailySales(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      final breakdown = await repo.getPaymentMethodBreakdown(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      final products = await repo.getTopSellingProducts(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      final z = await repo.generateZReport(date: state.endDate);

      final invValue = await repo.getInventoryValue();
      final lowStock = await repo.getLowStockItems();

      state = state.copyWith(
        isLoading: false,
        dailySales: sales,
        topProducts: products,
        zReport: z,
        paymentBreakdown: breakdown,
        inventoryValue: invValue,
        lowStockItems: lowStock,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end);
    loadReports();
  }
}
