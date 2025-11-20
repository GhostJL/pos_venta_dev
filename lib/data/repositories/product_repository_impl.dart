import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/product_model.dart';
import 'package:posventa/data/models/product_tax_model.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper databaseHelper;

  ProductRepositoryImpl(this.databaseHelper);

  @override
  Future<void> createProduct(Product product) async {
    final db = await databaseHelper.database;
    final productModel = ProductModel.fromEntity(product);
    await db.insert(DatabaseHelper.tableProducts, productModel.toMap());
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
    // Join with inventory to get stock
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock
      FROM ${DatabaseHelper.tableProducts} p
      WHERE p.is_active = 1
    ''');
    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
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
    return maps.map((map) => ProductModel.fromMap(map)).toList();
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
      return ProductModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> updateProduct(Product product) async {
    final db = await databaseHelper.database;
    final productModel = ProductModel.fromEntity(product);
    await db.update(
      DatabaseHelper.tableProducts,
      productModel.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
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
}
