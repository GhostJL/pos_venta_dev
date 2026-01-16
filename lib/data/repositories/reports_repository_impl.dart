import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';
import 'package:posventa/domain/repositories/reports_repository.dart';
import 'package:posventa/domain/entities/report_models.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final AppDatabase _db;

  ReportsRepositoryImpl(this._db);

  @override
  Future<List<SalesSummary>> getDailySales({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final saleDate = _db.sales.saleDate;
    final dayExpression = FunctionCallExpression<String>('strftime', [
      const Constant<String>('%Y-%m-%d'),
      saleDate,
      const Constant<String>('unixepoch'),
    ]);

    // Profit = Sum(Item.total - (Item.cost * Item.quantity))
    final profitExpression =
        (_db.saleItems.totalCents.cast<double>() -
                (_db.saleItems.costPriceCents.cast<double>() *
                    _db.saleItems.quantity))
            .sum();

    // Sum revenue from items to match the profit calculation scope
    final revenueSum = _db.saleItems.totalCents.sum();

    // Count distinct sales to avoid double counting due to join
    final transactionCount = _db.sales.id.count(distinct: true);

    final query =
        _db.selectOnly(_db.saleItems).join([
            innerJoin(_db.sales, _db.sales.id.equalsExp(_db.saleItems.saleId)),
          ])
          ..addColumns([
            dayExpression,
            revenueSum,
            transactionCount,
            profitExpression,
          ])
          ..where(saleDate.isBetweenValues(startDate, endDate))
          ..groupBy([dayExpression]);

    final result = await query.get();

    return result.map((row) {
      final dateStr = row.read(dayExpression);
      final date = DateTime.parse(dateStr!);
      final total = row.read(revenueSum) ?? 0;
      final count = row.read(transactionCount) ?? 0;
      final profit = row.read(profitExpression) ?? 0;

      return SalesSummary(
        date: date,
        totalSales: total / 100.0,
        transactionCount: count,
        profit: profit / 100.0,
      );
    }).toList();
  }

  @override
  Future<Map<String, double>> getPaymentMethodBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final paymentsQuery =
        _db.selectOnly(_db.salePayments).join([
            innerJoin(
              _db.sales,
              _db.sales.id.equalsExp(_db.salePayments.saleId),
            ),
          ])
          ..addColumns([
            _db.salePayments.paymentMethod,
            _db.salePayments.amountCents.sum(),
          ])
          ..where(_db.sales.saleDate.isBetweenValues(startDate, endDate))
          ..groupBy([_db.salePayments.paymentMethod]);

    final rows = await paymentsQuery.get();

    final Map<String, double> breakdown = {};
    for (var row in rows) {
      final method = row.read(_db.salePayments.paymentMethod)!;
      final amount =
          (row.read(_db.salePayments.amountCents.sum()) ?? 0) / 100.0;
      breakdown[method] = amount;
    }
    return breakdown;
  }

  @override
  Future<List<ProductPerformance>> getTopSellingProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    final quantitySum = _db.saleItems.quantity.sum();
    final revenueSum = _db.saleItems.totalCents.sum();

    // Profit = Revenue - Cost
    // Cost = unit_cost * quantity
    // We need an expression for profit sum.
    // Expression: Sum(total_cents - (cost_price_cents * quantity))
    final profitExpression =
        (_db.saleItems.totalCents.cast<double>() -
                (_db.saleItems.costPriceCents.cast<double>() *
                    _db.saleItems.quantity))
            .sum();

    final query = _db.selectOnly(_db.saleItems).join([
      innerJoin(_db.sales, _db.sales.id.equalsExp(_db.saleItems.saleId)),
      innerJoin(
        _db.products,
        _db.products.id.equalsExp(_db.saleItems.productId),
      ),
    ]);

    query
      ..addColumns([
        _db.products.id,
        _db.products.name,
        quantitySum,
        revenueSum,
        profitExpression,
      ])
      ..where(_db.sales.saleDate.isBetweenValues(startDate, endDate))
      ..groupBy([_db.saleItems.productId])
      ..orderBy([OrderingTerm.desc(revenueSum)])
      ..limit(limit);

    final rows = await query.get();

    return rows.map((row) {
      final productId = row.read(_db.products.id)!;
      final productName = row.read(_db.products.name)!;
      final qty = row.read(quantitySum) ?? 0;
      final rev = row.read(revenueSum) ?? 0;
      final profit = row.read(profitExpression) ?? 0;

      return ProductPerformance(
        productId: productId,
        productName: productName,
        quantitySold: qty,
        totalRevenue: rev / 100.0,
        totalProfit: profit / 100.0,
      );
    }).toList();
  }

  @override
  Future<ZReport> generateZReport({required DateTime date}) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    // 1. Sales Totals (One query)
    final salesQuery = _db.selectOnly(_db.sales)
      ..addColumns([
        _db.sales.totalCents.sum(),
        _db.sales.taxCents.sum(),
        _db.sales.id.count(),
      ])
      ..where(_db.sales.saleDate.isBetweenValues(start, end));

    final salesResult = await salesQuery.getSingle();
    final totalSales =
        (salesResult.read(_db.sales.totalCents.sum()) ?? 0) / 100.0;
    final totalTax = (salesResult.read(_db.sales.taxCents.sum()) ?? 0) / 100.0;
    final count = salesResult.read(_db.sales.id.count()) ?? 0;

    // 2. Payments Breakdown (Aggregated query)
    final paymentsQuery =
        _db.selectOnly(_db.salePayments).join([
            innerJoin(
              _db.sales,
              _db.sales.id.equalsExp(_db.salePayments.saleId),
            ),
          ])
          ..addColumns([
            _db.salePayments.paymentMethod,
            _db.salePayments.amountCents.sum(),
          ])
          ..where(_db.sales.saleDate.isBetweenValues(start, end))
          ..groupBy([_db.salePayments.paymentMethod]);

    final paymentRows = await paymentsQuery.get();

    final Map<String, double> paymentBreakdown = {};
    for (var row in paymentRows) {
      final method = row.read(_db.salePayments.paymentMethod)!;
      final amount =
          (row.read(_db.salePayments.amountCents.sum()) ?? 0) / 100.0;
      paymentBreakdown[method] = amount;
    }

    return ZReport(
      generatedAt: DateTime.now(),
      totalSales: totalSales,
      totalTax: totalTax,
      totalDiscounts: 0,
      transactionCount: count,
      paymentMethodBreakdown: paymentBreakdown,
    );
  }
}
