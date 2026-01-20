import 'package:drift/drift.dart';
import 'package:posventa/core/error/exceptions.dart';
import 'package:posventa/data/datasources/discount_local_datasource.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart';
import 'package:posventa/data/models/discount_model.dart';
import 'package:posventa/domain/entities/discount.dart' as dom;

// Removed typedef

class DiscountLocalDataSourceImpl implements DiscountLocalDataSource {
  final AppDatabase db;

  DiscountLocalDataSourceImpl(this.db);

  @override
  Future<List<dom.Discount>> getAllDiscounts() async {
    try {
      final query = db.select(db.discounts)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
      final rows = await query.get();
      return rows.map((row) => _mapRowToEntity(row)).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<dom.Discount>> getActiveDiscounts() async {
    try {
      final now = DateTime.now();
      final query = db.select(db.discounts)
        ..where((t) => t.isActive.equals(true))
        ..where(
          (t) => t.startDate.isNull() | t.startDate.isSmallerOrEqualValue(now),
        )
        ..where(
          (t) => t.endDate.isNull() | t.endDate.isBiggerOrEqualValue(now),
        );

      final rows = await query.get();
      return rows.map((row) => _mapRowToEntity(row)).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<dom.Discount?> getDiscountById(int id) async {
    try {
      final row = await (db.select(
        db.discounts,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return null;
      return _mapRowToEntity(row);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<int> createDiscount(DiscountModel discount) async {
    try {
      final id = await db
          .into(db.discounts)
          .insert(
            DiscountsCompanion.insert(
              name: discount.name,
              type: Value(
                discount.type == dom.DiscountType.percentage
                    ? 'percentage'
                    : 'amount',
              ),
              value: discount.value,
              startDate: Value(discount.startDate),
              endDate: Value(discount.endDate),
              isActive: Value(discount.isActive),
            ),
          );
      return id;
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> updateDiscount(DiscountModel discount) async {
    try {
      await (db.update(
        db.discounts,
      )..where((t) => t.id.equals(discount.id))).write(
        DiscountsCompanion(
          name: Value(discount.name),
          type: Value(
            discount.type == dom.DiscountType.percentage
                ? 'percentage'
                : 'amount',
          ),
          value: Value(discount.value),
          startDate: Value(discount.startDate),
          endDate: Value(discount.endDate),
          isActive: Value(discount.isActive),
        ),
      );
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteDiscount(int id) async {
    try {
      await (db.delete(db.discounts)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<dom.Discount>> getDiscountsForVariant(int variantId) async {
    try {
      final query = db.select(db.discounts).join([
        innerJoin(
          db.productVariantDiscounts,
          db.productVariantDiscounts.discountId.equalsExp(db.discounts.id),
        ),
      ])..where(db.productVariantDiscounts.variantId.equals(variantId));

      final rows = await query.get();
      return rows.map((row) {
        final discountRow = row.readTable(db.discounts);
        return _mapRowToEntity(discountRow);
      }).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> assignDiscountToVariant(int variantId, int discountId) async {
    try {
      await db
          .into(db.productVariantDiscounts)
          .insert(
            ProductVariantDiscountsCompanion.insert(
              variantId: variantId,
              discountId: discountId,
            ),
            mode: InsertMode.insertOrIgnore, // Prevent duplicates
          );
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> removeDiscountFromVariant(int variantId, int discountId) async {
    try {
      await (db.delete(db.productVariantDiscounts)..where(
            (t) =>
                t.variantId.equals(variantId) & t.discountId.equals(discountId),
          ))
          .go();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> updateVariantDiscounts(
    int variantId,
    List<int> discountIds,
  ) async {
    try {
      await db.transaction(() async {
        // Remove all
        await (db.delete(
          db.productVariantDiscounts,
        )..where((t) => t.variantId.equals(variantId))).go();

        // Add new
        for (final id in discountIds) {
          await db
              .into(db.productVariantDiscounts)
              .insert(
                ProductVariantDiscountsCompanion.insert(
                  variantId: variantId,
                  discountId: id,
                ),
              );
        }
      });
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  dom.Discount _mapRowToEntity(Discount row) {
    // row is the generated Drift class
    return dom.Discount(
      id: row.id,
      name: row.name,
      type: row.type == 'percentage'
          ? dom.DiscountType.percentage
          : dom.DiscountType.amount,
      value: row.value,
      startDate: row.startDate,
      endDate: row.endDate,
      isActive: row.isActive,
      createdAt: row.createdAt,
    );
  }
}
