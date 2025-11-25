import 'package:posventa/core/utils/database_validators.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/product_model.dart';
import 'package:posventa/data/models/product_tax_model.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/data/models/tax_rate_model.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper databaseHelper;

  ProductRepositoryImpl(this.databaseHelper);

  @override
  Future<int> createProduct(Product product) async {
    final db = await databaseHelper.database;
    final productModel = ProductModel.fromEntity(product);

    // Insert product and get its ID
    final productId = await db.insert(
      DatabaseHelper.tableProducts,
      productModel.toMap(),
    );

    // Save selected taxes from the form
    if (product.productTaxes != null && product.productTaxes!.isNotEmpty) {
      for (final tax in product.productTaxes!) {
        await db.insert(DatabaseHelper.tableProductTaxes, {
          'product_id': productId,
          'tax_rate_id': tax.taxRateId,
          'apply_order': tax.applyOrder,
        });
      }
    } else {
      // If no taxes selected, assign default tax (IVA_16)
      final defaultTaxResult = await db.query(
        DatabaseHelper.tableTaxRates,
        where: 'is_default = ? AND is_active = ?',
        whereArgs: [1, 1],
        limit: 1,
      );

      if (defaultTaxResult.isNotEmpty) {
        final defaultTaxId = defaultTaxResult.first['id'] as int;
        await db.insert(DatabaseHelper.tableProductTaxes, {
          'product_id': productId,
          'tax_rate_id': defaultTaxId,
          'apply_order': 1,
        });
      }
    }

    return productId;
  }

  @override
  Future<void> deleteProduct(int id) async {
    final db = await databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final db = await databaseHelper.database;

    // Query 1: Get all products with stock
    final List<Map<String, dynamic>> productMaps = await db.rawQuery('''
      SELECT p.*, (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock
      FROM ${DatabaseHelper.tableProducts} p
      WHERE p.is_active = 1
    ''');

    if (productMaps.isEmpty) return [];

    // Query 2: Get all taxes for these products in one query
    final productIds = productMaps.map((m) => m['id'] as int).toList();
    final taxMaps = await db.query(
      DatabaseHelper.tableProductTaxes,
      where: 'product_id IN (${productIds.join(',')})',
    );

    // Group taxes by product_id
    final taxesByProduct = <int, List<ProductTax>>{};
    for (final taxMap in taxMaps) {
      final productId = taxMap['product_id'] as int;
      taxesByProduct.putIfAbsent(productId, () => []);
      taxesByProduct[productId]!.add(ProductTaxModel.fromMap(taxMap));
    }

    // Build products with their taxes
    return productMaps.map((map) {
      final product = ProductModel.fromMap(map);
      final taxes = taxesByProduct[product.id!] ?? [];
      return product.copyWith(productTaxes: taxes.cast<ProductTax>());
    }).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final db = await databaseHelper.database;

    // Query 1: Search products with stock
    final List<Map<String, dynamic>> productMaps = await db.rawQuery(
      '''
      SELECT p.*, (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock
      FROM ${DatabaseHelper.tableProducts} p
      WHERE p.is_active = 1 AND (
        p.name LIKE ? OR 
        p.code LIKE ? OR 
        p.barcode LIKE ?
      )
    ''',
      ['%$query%', '%$query%', '%$query%'],
    );

    if (productMaps.isEmpty) return [];

    // Query 2: Get all taxes for these products in one query
    final productIds = productMaps.map((m) => m['id'] as int).toList();
    final taxMaps = await db.query(
      DatabaseHelper.tableProductTaxes,
      where: 'product_id IN (${productIds.join(',')})',
    );

    // Group taxes by product_id
    final taxesByProduct = <int, List<ProductTax>>{};
    for (final taxMap in taxMaps) {
      final productId = taxMap['product_id'] as int;
      taxesByProduct.putIfAbsent(productId, () => []);
      taxesByProduct[productId]!.add(ProductTaxModel.fromMap(taxMap));
    }

    // Build products with their taxes
    return productMaps.map((map) {
      final product = ProductModel.fromMap(map);
      final taxes = taxesByProduct[product.id!] ?? [];
      return product.copyWith(productTaxes: taxes.cast<ProductTax>());
    }).toList();
  }

  @override
  Future<Product?> getProductById(int id) async {
    final db = await databaseHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT p.*, (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock
      FROM ${DatabaseHelper.tableProducts} p
      WHERE p.id = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      final product = ProductModel.fromMap(maps.first);
      final taxes = await getTaxesForProduct(id);
      return product.copyWith(productTaxes: taxes.cast<ProductTax>());
    }

    return null;
  }

  @override
  Future<void> updateProduct(Product product) async {
    final db = await databaseHelper.database;
    final productModel = ProductModel.fromEntity(product);

    await db.transaction((txn) async {
      // Update product data
      await txn.update(
        DatabaseHelper.tableProducts,
        productModel.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );

      // Delete existing taxes
      await txn.delete(
        DatabaseHelper.tableProductTaxes,
        where: 'product_id = ?',
        whereArgs: [product.id],
      );

      // Insert updated taxes
      if (product.productTaxes != null && product.productTaxes!.isNotEmpty) {
        for (final tax in product.productTaxes!) {
          await txn.insert(DatabaseHelper.tableProductTaxes, {
            'product_id': product.id,
            'tax_rate_id': tax.taxRateId,
            'apply_order': tax.applyOrder,
          });
        }
      }
    });
  }

  @override
  Future<void> addTaxToProduct(ProductTax productTax) async {
    final db = await databaseHelper.database;
    final productTaxModel = ProductTaxModel.fromEntity(productTax);
    await db.insert(DatabaseHelper.tableProductTaxes, productTaxModel.toMap());
  }

  @override
  Future<List<ProductTax>> getTaxesForProduct(int productId) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableProductTaxes,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return maps.map((map) => ProductTaxModel.fromMap(map)).toList();
  }

  @override
  Future<void> removeTaxFromProduct(int productId, int taxRateId) async {
    final db = await databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableProductTaxes,
      where: 'product_id = ? AND tax_rate_id = ?',
      whereArgs: [productId, taxRateId],
    );
  }

  @override
  Future<List<TaxRate>> getTaxRatesForProduct(int productId) async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT tr.* 
      FROM ${DatabaseHelper.tableTaxRates} tr
      JOIN ${DatabaseHelper.tableProductTaxes} pt ON tr.id = pt.tax_rate_id
      WHERE pt.product_id = ?
    ''',
      [productId],
    );

    return result.map((map) => TaxRateModel.fromJson(map)).toList();
  }

  @override
  Future<bool> isCodeUnique(String code, {int? excludeId}) async {
    final db = await databaseHelper.database;
    return DatabaseValidators.isFieldUnique(
      db: db,
      tableName: DatabaseHelper.tableProducts,
      fieldName: 'code',
      value: code,
      excludeId: excludeId,
    );
  }

  @override
  Future<bool> isBarcodeUnique(String barcode, {int? excludeId}) async {
    final db = await databaseHelper.database;
    return DatabaseValidators.isFieldUnique(
      db: db,
      tableName: DatabaseHelper.tableProducts,
      fieldName: 'barcode',
      value: barcode,
      excludeId: excludeId,
    );
  }
}
