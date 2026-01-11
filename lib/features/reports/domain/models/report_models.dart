class SalesSummary {
  final DateTime date;
  final double totalSales;
  final int transactionCount;
  final double profit;

  const SalesSummary({
    required this.date,
    required this.totalSales,
    required this.transactionCount,
    required this.profit,
  });
}

class ProductPerformance {
  final int productId;
  final String productName;
  final double quantitySold;
  final double totalRevenue;
  final double totalProfit;

  const ProductPerformance({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
    required this.totalProfit,
  });
}

class ZReport {
  final DateTime generatedAt;
  final double totalSales;
  final double totalTax;
  final double totalDiscounts;
  final int transactionCount;
  final Map<String, double> paymentMethodBreakdown;

  const ZReport({
    required this.generatedAt,
    required this.totalSales,
    required this.totalTax,
    required this.totalDiscounts,
    required this.transactionCount,
    required this.paymentMethodBreakdown,
  });
}
