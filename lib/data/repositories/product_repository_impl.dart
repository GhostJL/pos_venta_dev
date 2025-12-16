import 'package:posventa/core/utils/database_validators.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/product_model.dart';
import 'package:posventa/data/models/product_tax_model.dart';
import 'package:posventa/data/models/product_variant_model.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/data/models/tax_rate_model.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper databaseHelper;

  ProductRepositoryImpl(this.databaseHelper);

  @override
  Stream<List<Product>> getAllProductsStream() async* {
    yield await getAllProducts();
    await for (final table in databaseHelper.tableUpdateStream) {
      if (table == DatabaseHelper.tableProducts ||
          table == DatabaseHelper.tableInventory ||
          table == DatabaseHelper.tableProductVariants) {
        yield await getAllProducts();
      }
    }
  }

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

    // Save variants
    if (product.variants != null && product.variants!.isNotEmpty) {
      for (final variant in product.variants!) {
        final variantModel = ProductVariantModel.fromEntity(variant);
        final variantMap = variantModel.toMap();
        variantMap['product_id'] = productId;
        // Remove id to let autoincrement work
        variantMap.remove('id');
        await db.insert(DatabaseHelper.tableProductVariants, variantMap);
      }
    }

    databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
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
    databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final db = await databaseHelper.database;

    // Query 1: Get all products with stock
    final List<Map<String, dynamic>> productMaps = await db.rawQuery('''
      SELECT p.*, 
             (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock,
             u.name as unit_name,
             d.name as department_name
      FROM ${DatabaseHelper.tableProducts} p
      LEFT JOIN ${DatabaseHelper.tableUnitsOfMeasure} u ON p.unit_id = u.id
      LEFT JOIN ${DatabaseHelper.tableDepartments} d ON p.department_id = d.id
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

    // Query 3: Get all variants for these products
    final variantMaps = await db.rawQuery('''
      SELECT pv.*, 
             (SELECT SUM(quantity) FROM ${DatabaseHelper.tableInventoryLots} WHERE variant_id = pv.id) as stock
      FROM ${DatabaseHelper.tableProductVariants} pv
      WHERE pv.product_id IN (${productIds.join(',')}) AND pv.is_active = 1
    ''');

    // Group variants by product_id
    final variantsByProduct = <int, List<ProductVariantModel>>{};
    for (final variantMap in variantMaps) {
      final productId = variantMap['product_id'] as int;
      variantsByProduct.putIfAbsent(productId, () => []);
      variantsByProduct[productId]!.add(
        ProductVariantModel.fromMap(variantMap),
      );
    }

    // Build products with their taxes and variants
    return productMaps.map((map) {
      final product = ProductModel.fromMap(map);
      final taxes = taxesByProduct[product.id!] ?? [];
      final variants = variantsByProduct[product.id!] ?? [];
      return product.copyWith(
        productTaxes: taxes.cast<ProductTax>(),
        variants: variants.cast<ProductVariant>(),
      );
    }).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final db = await databaseHelper.database;

    // Query 1: Search products with stock
    final List<Map<String, dynamic>> productMaps = await db.rawQuery(
      '''
      SELECT DISTINCT p.*, 
             (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock,
             u.name as unit_name,
             d.name as department_name
      FROM ${DatabaseHelper.tableProducts} p
      LEFT JOIN ${DatabaseHelper.tableProductVariants} pv ON p.id = pv.product_id AND pv.is_active = 1
      LEFT JOIN ${DatabaseHelper.tableUnitsOfMeasure} u ON p.unit_id = u.id
      LEFT JOIN ${DatabaseHelper.tableDepartments} d ON p.department_id = d.id
      WHERE p.is_active = 1 AND (
        p.name LIKE ? OR 
        p.code LIKE ? OR 
        pv.barcode LIKE ? OR
        pv.variant_name LIKE ?
      )
    ''',
      ['%$query%', '%$query%', '%$query%', '%$query%'],
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

    // Query 3: Get all variants for these products
    final variantMaps = await db.rawQuery('''
      SELECT pv.*, 
             (SELECT SUM(quantity) FROM ${DatabaseHelper.tableInventoryLots} WHERE variant_id = pv.id) as stock
      FROM ${DatabaseHelper.tableProductVariants} pv
      WHERE pv.product_id IN (${productIds.join(',')}) AND pv.is_active = 1
    ''');

    // Group variants by product_id
    final variantsByProduct = <int, List<ProductVariantModel>>{};
    for (final variantMap in variantMaps) {
      final productId = variantMap['product_id'] as int;
      variantsByProduct.putIfAbsent(productId, () => []);
      variantsByProduct[productId]!.add(
        ProductVariantModel.fromMap(variantMap),
      );
    }

    // Build products with their taxes and variants
    return productMaps.map((map) {
      final product = ProductModel.fromMap(map);
      final taxes = taxesByProduct[product.id!] ?? [];
      final variants = variantsByProduct[product.id!] ?? [];
      return product.copyWith(
        productTaxes: taxes.cast<ProductTax>(),
        variants: variants.cast<ProductVariant>(),
      );
    }).toList();
  }

  @override
  Future<Product?> getProductById(int id) async {
    final db = await databaseHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT p.*, 
             (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock,
             u.name as unit_name,
             d.name as department_name
      FROM ${DatabaseHelper.tableProducts} p
      LEFT JOIN ${DatabaseHelper.tableUnitsOfMeasure} u ON p.unit_id = u.id
      LEFT JOIN ${DatabaseHelper.tableDepartments} d ON p.department_id = d.id
      WHERE p.id = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      final product = ProductModel.fromMap(maps.first);
      final taxes = await getTaxesForProduct(id);

      // Get variants
      final variantMaps = await db.rawQuery(
        '''
        SELECT pv.*, 
               (SELECT SUM(quantity) FROM ${DatabaseHelper.tableInventoryLots} WHERE variant_id = pv.id) as stock
        FROM ${DatabaseHelper.tableProductVariants} pv
        WHERE pv.product_id = ? AND pv.is_active = 1
      ''',
        [id],
      );
      final variants = variantMaps
          .map((m) => ProductVariantModel.fromMap(m))
          .toList();

      return product.copyWith(
        productTaxes: taxes.cast<ProductTax>(),
        variants: variants.cast<ProductVariant>(),
      );
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

      // --- HANDLE VARIANTS (Smart Update) ---

      // 1. Get existing variant IDs for this product
      final existingVariantMaps = await txn.query(
        DatabaseHelper.tableProductVariants,
        columns: ['id'],
        where: 'product_id = ?',
        whereArgs: [product.id],
      );
      final existingIds = existingVariantMaps
          .map((m) => m['id'] as int)
          .toList();

      final newVariants = product.variants ?? [];
      final newVariantIds = newVariants
          .where((v) => v.id != null)
          .map((v) => v.id!)
          .toList();

      // 2. Delete variants that are no longer present
      final idsToDelete = existingIds
          .where((id) => !newVariantIds.contains(id))
          .toList();
      if (idsToDelete.isNotEmpty) {
        await txn.delete(
          DatabaseHelper.tableProductVariants,
          where: 'id IN (${idsToDelete.join(',')})',
        );
      }

      // 3. Update or Insert variants
      for (final variant in newVariants) {
        final variantModel = ProductVariantModel.fromEntity(variant);
        final variantMap = variantModel.toMap();
        variantMap['product_id'] = product.id;

        if (variant.id != null && existingIds.contains(variant.id)) {
          // Update existing
          await txn.update(
            DatabaseHelper.tableProductVariants,
            variantMap,
            where: 'id = ?',
            whereArgs: [variant.id],
          );
        } else {
          // Insert new (remove id to ensure autoincrement works if it was somehow set to 0 or null placeholder)
          variantMap.remove('id');
          await txn.insert(DatabaseHelper.tableProductVariants, variantMap);
        }
      }
    });
    databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
  }

  @override
  Future<void> addTaxToProduct(ProductTax productTax) async {
    final db = await databaseHelper.database;
    final productTaxModel = ProductTaxModel.fromEntity(productTax);
    await db.insert(DatabaseHelper.tableProductTaxes, productTaxModel.toMap());
    databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
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
    databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
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
  Future<bool> isBarcodeUnique(
    String barcode, {
    int? excludeId,
    int? excludeVariantId,
  }) async {
    final db = await databaseHelper.database;

    // Check if barcode exists in product_variants table
    final variantsResult = await db.query(
      DatabaseHelper.tableProductVariants,
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (variantsResult.isEmpty) {
      return true; // Barcode doesn't exist, it's unique
    }

    // If we're excluding a specific variant (editing), check if the found barcode belongs to it
    if (excludeVariantId != null) {
      // Filter out the variant we're editing
      final otherVariants = variantsResult
          .where((v) => v['id'] != excludeVariantId)
          .toList();

      return otherVariants
          .isEmpty; // Unique if no other variants have this barcode
    }

    // If we're excluding a product (for backward compatibility)
    if (excludeId != null) {
      // Check if all found variants belong to the product we're editing
      final otherProductVariants = variantsResult
          .where((v) => v['product_id'] != excludeId)
          .toList();

      return otherProductVariants.isEmpty;
    }

    // Barcode exists and we're not excluding anything
    return false;
  }

  @override
  Future<int> saveVariant(ProductVariant variant) async {
    final db = await databaseHelper.database;
    final variantModel = ProductVariantModel.fromEntity(variant);
    final variantMap = variantModel.toMap();
    variantMap.remove('id'); // Ensure ID is generated

    final id = await db.insert(DatabaseHelper.tableProductVariants, variantMap);
    databaseHelper.notifyTableChanged(DatabaseHelper.tableProductVariants);
    return id;
  }

  @override
  Future<void> updateVariant(ProductVariant variant) async {
    final db = await databaseHelper.database;
    final variantModel = ProductVariantModel.fromEntity(variant);

    await db.update(
      DatabaseHelper.tableProductVariants,
      variantModel.toMap(),
      where: 'id = ?',
      whereArgs: [variant.id],
    );
    databaseHelper.notifyTableChanged(DatabaseHelper.tableProductVariants);
  }
}
