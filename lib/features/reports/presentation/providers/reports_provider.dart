import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/features/reports/domain/models/report_models.dart';
import 'package:posventa/presentation/providers/di/reports_di.dart';

part 'reports_provider.g.dart';

class ReportsState {
  final bool isLoading;
  final List<SalesSummary> dailySales;
  final List<ProductPerformance> topProducts;
  final ZReport? zReport;
  final DateTime startDate;
  final DateTime endDate;

  const ReportsState({
    this.isLoading = false,
    this.dailySales = const [],
    this.topProducts = const [],
    this.zReport,
    required this.startDate,
    required this.endDate,
  });

  ReportsState copyWith({
    bool? isLoading,
    List<SalesSummary>? dailySales,
    List<ProductPerformance>? topProducts,
    ZReport? zReport,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      dailySales: dailySales ?? this.dailySales,
      topProducts: topProducts ?? this.topProducts,
      zReport: zReport ?? this.zReport,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
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

      final products = await repo.getTopSellingProducts(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      final z = await repo.generateZReport(date: state.endDate);

      state = state.copyWith(
        isLoading: false,
        dailySales: sales,
        topProducts: products,
        zReport: z,
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
