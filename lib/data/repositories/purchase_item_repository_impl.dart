import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/purchase_item_model.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';

class PurchaseItemRepositoryImpl implements PurchaseItemRepository {
  final drift_db.AppDatabase db;

  PurchaseItemRepositoryImpl(this.db);

  @override
  Future<List<PurchaseItem>> getPurchaseItems() async {
    final q = db.select(db.purchaseItems).join([
      leftOuterJoin(
        db.products,
        db.products.id.equalsExp(db.purchaseItems.productId),
      ),
      leftOuterJoin(
        db.productVariants,
        db.productVariants.id.equalsExp(db.purchaseItems.variantId),
      ),
      leftOuterJoin(
        db.purchases,
        db.purchases.id.equalsExp(db.purchaseItems.purchaseId),
      ),
      leftOuterJoin(
        db.suppliers,
        db.suppliers.id.equalsExp(db.purchases.supplierId),
      ),
    ])..orderBy([OrderingTerm.desc(db.purchaseItems.createdAt)]);

    final rows = await q.get();
    return rows.map((row) => _mapRow(row)).toList();
  }

  @override
  Future<List<PurchaseItem>> getPurchaseItemsByPurchaseId(
    int purchaseId,
  ) async {
    final q =
        db.select(db.purchaseItems).join([
            leftOuterJoin(
              db.products,
              db.products.id.equalsExp(db.purchaseItems.productId),
            ),
            leftOuterJoin(
              db.productVariants,
              db.productVariants.id.equalsExp(db.purchaseItems.variantId),
            ),
            leftOuterJoin(
              db.purchases,
              db.purchases.id.equalsExp(db.purchaseItems.purchaseId),
            ),
            leftOuterJoin(
              db.suppliers,
              db.suppliers.id.equalsExp(db.purchases.supplierId),
            ),
          ])
          ..where(db.purchaseItems.purchaseId.equals(purchaseId))
          ..orderBy([OrderingTerm.desc(db.purchaseItems.createdAt)]);

    final rows = await q.get();
    return rows.map((row) => _mapRow(row)).toList();
  }

  @override
  Future<PurchaseItem?> getPurchaseItemById(int id) async {
    final q = db.select(db.purchaseItems).join([
      leftOuterJoin(
        db.products,
        db.products.id.equalsExp(db.purchaseItems.productId),
      ),
      leftOuterJoin(
        db.productVariants,
        db.productVariants.id.equalsExp(db.purchaseItems.variantId),
      ),
      leftOuterJoin(
        db.purchases,
        db.purchases.id.equalsExp(db.purchaseItems.purchaseId),
      ),
      leftOuterJoin(
        db.suppliers,
        db.suppliers.id.equalsExp(db.purchases.supplierId),
      ),
    ])..where(db.purchaseItems.id.equals(id));

    final row = await q.getSingleOrNull();
    if (row == null) return null;
    return _mapRow(row);
  }

  @override
  Future<List<PurchaseItem>> getPurchaseItemsByProductId(int productId) async {
    final q =
        db.select(db.purchaseItems).join([
            leftOuterJoin(
              db.products,
              db.products.id.equalsExp(db.purchaseItems.productId),
            ),
            leftOuterJoin(
              db.productVariants,
              db.productVariants.id.equalsExp(db.purchaseItems.variantId),
            ),
            leftOuterJoin(
              db.purchases,
              db.purchases.id.equalsExp(db.purchaseItems.purchaseId),
            ),
            leftOuterJoin(
              db.suppliers,
              db.suppliers.id.equalsExp(db.purchases.supplierId),
            ),
          ])
          ..where(db.purchaseItems.productId.equals(productId))
          ..orderBy([OrderingTerm.desc(db.purchaseItems.createdAt)]);

    final rows = await q.get();
    return rows.map((row) => _mapRow(row)).toList();
  }

  @override
  Future<int> createPurchaseItem(PurchaseItem item) async {
    return await db
        .into(db.purchaseItems)
        .insert(
          drift_db.PurchaseItemsCompanion.insert(
            purchaseId: item.purchaseId!,
            productId: item.productId,
            variantId: Value(item.variantId),
            quantity: item.quantity,
            unitOfMeasure: item.unitOfMeasure,
            unitCostCents: item.unitCostCents,
            subtotalCents: item.subtotalCents,
            taxCents: Value(item.taxCents),
            totalCents: item.totalCents,
            lotId: Value(item.lotId),
            expirationDate: Value(item.expirationDate),
            createdAt: Value(item.createdAt),
          ),
        );
  }

  @override
  Future<void> updatePurchaseItem(PurchaseItem item) async {
    await (db.update(
      db.purchaseItems,
    )..where((t) => t.id.equals(item.id!))).write(
      drift_db.PurchaseItemsCompanion(
        quantity: Value(item.quantity),
        unitCostCents: Value(item.unitCostCents),
        subtotalCents: Value(item.subtotalCents),
        taxCents: Value(item.taxCents),
        totalCents: Value(item.totalCents),
        lotId: Value(item.lotId),
        expirationDate: Value(item.expirationDate),
      ),
    );
  }

  @override
  Future<void> deletePurchaseItem(int id) async {
    await (db.delete(db.purchaseItems)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<PurchaseItem>> getPurchaseItemsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final q =
        db.select(db.purchaseItems).join([
            leftOuterJoin(
              db.products,
              db.products.id.equalsExp(db.purchaseItems.productId),
            ),
            leftOuterJoin(
              db.productVariants,
              db.productVariants.id.equalsExp(db.purchaseItems.variantId),
            ),
            leftOuterJoin(
              db.purchases,
              db.purchases.id.equalsExp(db.purchaseItems.purchaseId),
            ),
            leftOuterJoin(
              db.suppliers,
              db.suppliers.id.equalsExp(db.purchases.supplierId),
            ),
          ])
          ..where(
            db.purchaseItems.createdAt.isBetweenValues(startDate, endDate),
          )
          ..orderBy([OrderingTerm.desc(db.purchaseItems.createdAt)]);

    final rows = await q.get();
    return rows.map((row) => _mapRow(row)).toList();
  }

  @override
  Future<List<PurchaseItem>> getRecentPurchaseItems({int limit = 50}) async {
    final q =
        db.select(db.purchaseItems).join([
            leftOuterJoin(
              db.products,
              db.products.id.equalsExp(db.purchaseItems.productId),
            ),
            leftOuterJoin(
              db.productVariants,
              db.productVariants.id.equalsExp(db.purchaseItems.variantId),
            ),
            leftOuterJoin(
              db.purchases,
              db.purchases.id.equalsExp(db.purchaseItems.purchaseId),
            ),
            leftOuterJoin(
              db.suppliers,
              db.suppliers.id.equalsExp(db.purchases.supplierId),
            ),
          ])
          ..orderBy([OrderingTerm.desc(db.purchaseItems.createdAt)])
          ..limit(limit);

    final rows = await q.get();
    return rows.map((row) => _mapRow(row)).toList();
  }

  PurchaseItemModel _mapRow(TypedResult row) {
    final item = row.readTable(db.purchaseItems);
    final product = row.readTableOrNull(db.products);
    final variant = row.readTableOrNull(db.productVariants);

    // Construct ProductName
    String? productName = product?.name;
    if (productName != null && variant != null) {
      productName = '$productName (${variant.variantName})';
    }

    return PurchaseItemModel(
      id: item.id,
      purchaseId: item.purchaseId,
      productId: item.productId,
      variantId: item.variantId,
      quantity: item.quantity,
      quantityReceived: item.quantityReceived,
      unitOfMeasure: item.unitOfMeasure,
      unitCostCents: item.unitCostCents,
      subtotalCents: item.subtotalCents,
      taxCents: item.taxCents,
      totalCents: item.totalCents,
      lotId: item.lotId,
      expirationDate: item.expirationDate,
      createdAt: item.createdAt,
      productName: productName,
    );
  }
}
