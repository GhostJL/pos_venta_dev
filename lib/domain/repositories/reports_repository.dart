import 'package:posventa/domain/entities/report_models.dart';

abstract class ReportsRepository {
  Future<List<SalesSummary>> getDailySales({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<ProductPerformance>> getTopSellingProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  });

  Future<Map<String, double>> getPaymentMethodBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<ZReport> generateZReport({required DateTime date});

  Future<double> getInventoryValue();

  Future<List<LowStockItem>> getLowStockItems({int limit = 10});
}
