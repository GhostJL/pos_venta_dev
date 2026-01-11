import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';
import 'package:posventa/domain/repositories/reports_repository.dart';
import 'package:posventa/features/reports/domain/models/report_models.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final AppDatabase _db;

  ReportsRepositoryImpl(this._db);

  @override
  Future<List<SalesSummary>> getDailySales({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Group by date (ignoring time)
    // Drift query to aggregate sales
    // Since Drift's Dart API for complex grouping can be verbose, we can use custom SQL or iteration if dataset is small.
    // For scalability, SQL is better.
    // SELECT date(sale_date, 'unixepoch') as day, SUM(total_cents), COUNT(*) FROM sales ...

    // However, given the project structure, let's try to stick to Dart API if possible or specific custom queries.
    // Let's iterate for now or use a custom query if the API exposes it.
    // Accessing tables directly from _db.

    final query = _db.select(_db.sales)
      ..where((tbl) => tbl.saleDate.isBetweenValues(startDate, endDate));

    final sales = await query.get();

    // In-memory aggregation for MVP (Optimize to SQL later if needed)
    final Map<DateTime, List<Sale>> grouped = {};
    for (var sale in sales) {
      final date = DateTime(
        sale.saleDate.year,
        sale.saleDate.month,
        sale.saleDate.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(sale);
    }

    return grouped.entries.map((entry) {
      final date = entry.key;
      final specificSales = entry.value;

      double total = 0;
      double profit = 0; // Requires linking to items and costs.
      // For profit, we need to join or fetch items. To keep it fast, maybe just Total Revenue first.

      total = specificSales.fold(0, (sum, s) => sum + s.totalCents);

      return SalesSummary(
        date: date,
        totalSales: total / 100.0,
        transactionCount: specificSales.length,
        profit: 0, // Placeholder until cost logic is fully joined
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<List<ProductPerformance>> getTopSellingProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    // Need to join Sales -> SaleItems -> Products
    // This is better done with a custom query or a join.

    final query = _db.select(_db.saleItems).join([
      innerJoin(_db.sales, _db.sales.id.equalsExp(_db.saleItems.saleId)),
      innerJoin(
        _db.products,
        _db.products.id.equalsExp(_db.saleItems.productId),
      ),
    ]);
    query.where(_db.sales.saleDate.isBetweenValues(startDate, endDate));

    final rows = await query.get();

    final Map<int, ProductPerformance> performanceMap = {};

    for (var row in rows) {
      final item = row.readTable(_db.saleItems);
      // final sale = row.readTable(_db.sales);
      final product = row.readTable(_db.products);

      final current =
          performanceMap[item.productId] ??
          ProductPerformance(
            productId: item.productId,
            productName: product.name,
            quantitySold: 0,
            totalRevenue: 0,
            totalProfit: 0,
          );

      final revenue = item.totalCents / 100.0;
      final cost = (item.costPriceCents * item.quantity) / 100.0;

      performanceMap[item.productId] = ProductPerformance(
        productId: current.productId,
        productName: current.productName,
        quantitySold: current.quantitySold + item.quantity,
        totalRevenue: current.totalRevenue + revenue,
        totalProfit: current.totalProfit + (revenue - cost),
      );
    }

    final sorted = performanceMap.values.toList()
      ..sort(
        (a, b) => b.totalRevenue.compareTo(a.totalRevenue),
      ); // Descending revenue

    return sorted.take(limit).toList();
  }

  @override
  Future<ZReport> generateZReport({required DateTime date}) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final dailySales =
        await (_db.sales.select()
              ..where((tbl) => tbl.saleDate.isBetweenValues(start, end)))
            .get();

    double totalSales = 0;
    double totalTax = 0;

    // We assume discount logic is embedded in totals or we'd summon it from items if needed.
    // Sale entity has total, tax, subtotal.

    final Map<String, double> paymentBreakdown = {};

    // Need to fetch payments for these sales
    // Or just iterate if we can load them eagerly. Use separate query for payments linked to these sales.
    final saleIds = dailySales.map((s) => s.id).toList();

    if (saleIds.isNotEmpty) {
      final payments = await (_db.select(
        _db.salePayments,
      )..where((tbl) => tbl.saleId.isIn(saleIds))).get();
      for (var payment in payments) {
        final method = payment.paymentMethod;
        paymentBreakdown[method] =
            (paymentBreakdown[method] ?? 0) + (payment.amountCents / 100.0);
      }
    }

    for (var sale in dailySales) {
      totalSales += sale.totalCents;
      totalTax += sale.taxCents;
    }

    return ZReport(
      generatedAt: DateTime.now(),
      totalSales: totalSales / 100.0,
      totalTax: totalTax / 100.0,
      totalDiscounts: 0, // Implement if discount field exists or sum from items
      transactionCount: dailySales.length,
      paymentMethodBreakdown: paymentBreakdown,
    );
  }
}
