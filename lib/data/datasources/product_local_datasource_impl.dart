import 'dart:async';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:posventa/core/utils/database_validators.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/datasources/product_local_datasource.dart';
import 'package:posventa/data/models/product_model.dart';
import 'package:posventa/data/models/product_tax_model.dart';
import 'package:posventa/data/models/product_variant_model.dart';
import 'package:posventa/data/models/tax_rate_model.dart';
import 'package:posventa/core/error/exceptions.dart';

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final DatabaseHelper databaseHelper;

  ProductLocalDataSourceImpl(this.databaseHelper);

  @override
  Stream<String> get tableUpdateStream => databaseHelper.tableUpdateStream;

  @override
  Future<List<ProductModel>> getAllProducts({int? limit, int? offset}) async {
    try {
      final db = await databaseHelper.database;

      // Query 1: Get all products with stock
      final List<Map<String, dynamic>> productMaps = await db.rawQuery('''
        SELECT p.*, 
               (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock,
               d.name as department_name
        FROM ${DatabaseHelper.tableProducts} p
        LEFT JOIN ${DatabaseHelper.tableDepartments} d ON p.department_id = d.id
        ORDER BY p.id DESC
        ${limit != null ? 'LIMIT $limit' : ''}
        ${offset != null ? 'OFFSET $offset' : ''}
      ''');

      if (productMaps.isEmpty) return [];

      // Query 2: Get all taxes for these products
      final productIds = productMaps.map((m) => m['id'] as int).toList();
      final taxMaps = await db.query(
        DatabaseHelper.tableProductTaxes,
        where: 'product_id IN (${productIds.join(',')})',
      );

      final taxesByProduct = <int, List<ProductTaxModel>>{};
      for (final taxMap in taxMaps) {
        final productId = taxMap['product_id'] as int;
        taxesByProduct.putIfAbsent(productId, () => []);
        taxesByProduct[productId]!.add(ProductTaxModel.fromMap(taxMap));
      }

      // Query 3: Get variants using helper
      final variantsByProduct = await _getVariantsForProducts(db, productIds);

      // Build products
      return productMaps.map((map) {
        final product = ProductModel.fromMap(map);
        final taxes = taxesByProduct[product.id!] ?? [];
        final variants = variantsByProduct[product.id!] ?? [];
        return ProductModel.fromEntity(
          product.copyWith(productTaxes: taxes, variants: variants),
        );
      }).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final db = await databaseHelper.database;

      // Query 1: Search products with stock
      final List<Map<String, dynamic>> productMaps = await db.rawQuery(
        '''
        SELECT DISTINCT p.*, 
               (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock,
               d.name as department_name
        FROM ${DatabaseHelper.tableProducts} p
        LEFT JOIN ${DatabaseHelper.tableProductVariants} pv ON p.id = pv.product_id AND pv.is_active = 1
        LEFT JOIN ${DatabaseHelper.tableProductBarcodes} pb ON pv.id = pb.variant_id
        LEFT JOIN ${DatabaseHelper.tableDepartments} d ON p.department_id = d.id
        WHERE (
          p.name LIKE ? OR 
          p.code LIKE ? OR 
          pv.barcode LIKE ? OR
          pv.variant_name LIKE ? OR
          pb.barcode LIKE ?
        )
        ORDER BY p.id DESC
      ''',
        ['%$query%', '%$query%', '%$query%', '%$query%', '%$query%'],
      );

      if (productMaps.isEmpty) return [];

      // Query 2: Get all taxes for these products in one query
      final productIds = productMaps.map((m) => m['id'] as int).toList();
      final taxMaps = await db.query(
        DatabaseHelper.tableProductTaxes,
        where: 'product_id IN (${productIds.join(',')})',
      );

      // Group taxes by product_id
      final taxesByProduct = <int, List<ProductTaxModel>>{};
      for (final taxMap in taxMaps) {
        final productId = taxMap['product_id'] as int;
        taxesByProduct.putIfAbsent(productId, () => []);
        taxesByProduct[productId]!.add(ProductTaxModel.fromMap(taxMap));
      }

      // Query 3: Get variants using helper
      final variantsByProduct = await _getVariantsForProducts(db, productIds);

      return productMaps.map((map) {
        final product = ProductModel.fromMap(map);
        final taxes = taxesByProduct[product.id!] ?? [];
        final variants = variantsByProduct[product.id!] ?? [];
        // Fix cast error using fromEntity
        return ProductModel.fromEntity(
          product.copyWith(productTaxes: taxes, variants: variants),
        );
      }).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<ProductModel?> getProductById(int id) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.rawQuery(
        '''
        SELECT p.*, 
               (SELECT SUM(quantity_on_hand) FROM inventory WHERE product_id = p.id) as stock,
               d.name as department_name
        FROM ${DatabaseHelper.tableProducts} p
        LEFT JOIN ${DatabaseHelper.tableDepartments} d ON p.department_id = d.id
        WHERE p.id = ?
      ''',
        [id],
      );

      if (maps.isNotEmpty) {
        final product = ProductModel.fromMap(maps.first);
        final taxes = await getTaxesForProduct(id);

        // Get variants using helper
        final variantsByProduct = await _getVariantsForProducts(db, [id]);
        final variants = variantsByProduct[id] ?? [];

        // Fix cast error using fromEntity
        return ProductModel.fromEntity(
          product.copyWith(productTaxes: taxes, variants: variants),
        );
      }
      return null;
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> batchCreateProducts(
    List<ProductModel> products, {
    required int defaultWarehouseId,
  }) async {
    try {
      final db = await databaseHelper.database;
      await db.transaction((txn) async {
        // Fetch the default tax once to use if no taxes provided
        final defaultTaxResult = await txn.query(
          DatabaseHelper.tableTaxRates,
          where: 'is_default = ? AND is_active = ?',
          whereArgs: [1, 1],
          limit: 1,
        );

        int? defaultTaxId;
        if (defaultTaxResult.isNotEmpty) {
          defaultTaxId = defaultTaxResult.first['id'] as int;
        }

        for (final product in products) {
          // Insert product
          final productId = await txn.insert(
            DatabaseHelper.tableProducts,
            product.toMap(),
          );

          // Save taxes
          if (product.productTaxes != null &&
              product.productTaxes!.isNotEmpty) {
            for (final tax in product.productTaxes!) {
              await txn.insert(DatabaseHelper.tableProductTaxes, {
                'product_id': productId,
                'tax_rate_id': tax.taxRateId,
                'apply_order': tax.applyOrder,
              });
            }
          } else if (defaultTaxId != null) {
            await txn.insert(DatabaseHelper.tableProductTaxes, {
              'product_id': productId,
              'tax_rate_id': defaultTaxId,
              'apply_order': 1,
            });
          }

          // Save variants
          if (product.variants != null && product.variants!.isNotEmpty) {
            for (final variant in product.variants!) {
              final variantModel = ProductVariantModel.fromEntity(variant);
              final variantMap = variantModel.toMap();

              // Extract additional barcodes to prevent error on insert into product_variants
              final additionalBarcodes =
                  variantMap.remove('additional_barcodes') as List<String>?;

              variantMap['product_id'] = productId;
              // Remove id to let autoincrement work
              variantMap.remove('id');
              final variantId = await txn.insert(
                DatabaseHelper.tableProductVariants,
                variantMap,
              );

              // Insert additional barcodes
              if (additionalBarcodes != null) {
                for (final code in additionalBarcodes) {
                  await txn.insert(DatabaseHelper.tableProductBarcodes, {
                    'variant_id': variantId,
                    'barcode': code,
                  });
                }
              }

              // --- INITIAL LOT CREATION ---
              // If stock > 0, create an initial lot for this variant
              if (variant.stock != null && variant.stock! > 0) {
                // 1. Create Lot
                await txn.insert(DatabaseHelper.tableInventoryLots, {
                  'product_id': productId,
                  'variant_id': variantId,
                  'warehouse_id': defaultWarehouseId,
                  'lot_number': 'Inicial',
                  'quantity': variant.stock,
                  'unit_cost_cents': variant.costPriceCents,
                  'total_cost_cents': (variant.stock! * variant.costPriceCents)
                      .round(),
                  'received_at': DateTime.now().toIso8601String(),
                });

                // 2. Update/Insert Inventory Summary (for the dashboard/product list queries)
                // Check if exists
                final inventoryCheck = await txn.query(
                  DatabaseHelper.tableInventory,
                  where:
                      'product_id = ? AND warehouse_id = ? AND variant_id = ?',
                  whereArgs: [productId, defaultWarehouseId, variantId],
                );

                if (inventoryCheck.isNotEmpty) {
                  // This shouldn't happen for new products but good for robustness
                  final currentQty =
                      inventoryCheck.first['quantity_on_hand'] as num;
                  await txn.update(
                    DatabaseHelper.tableInventory,
                    {
                      'quantity_on_hand':
                          currentQty.toDouble() + variant.stock!,
                    },
                    where: 'id = ?',
                    whereArgs: [inventoryCheck.first['id']],
                  );
                } else {
                  await txn.insert(DatabaseHelper.tableInventory, {
                    'product_id': productId,
                    'warehouse_id': defaultWarehouseId,
                    'variant_id': variantId,
                    'quantity_on_hand': variant.stock,
                    'quantity_reserved': 0,
                    'updated_at': DateTime.now().toIso8601String(),
                  });
                }
              }
            }
          }
        }
      });
      databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
      databaseHelper.notifyTableChanged(DatabaseHelper.tableInventoryLots);
      databaseHelper.notifyTableChanged(DatabaseHelper.tableInventory);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<int> createProduct(ProductModel product) async {
    try {
      final db = await databaseHelper.database;
      return await db.transaction((txn) async {
        // Fetch default warehouse ID
        int defaultWarehouseId = 1; // Fallback
        final warehouses = await txn.query(
          DatabaseHelper.tableWarehouses,
          limit: 1,
        );
        if (warehouses.isNotEmpty) {
          defaultWarehouseId = warehouses.first['id'] as int;
        }

        // Insert product
        final productId = await txn.insert(
          DatabaseHelper.tableProducts,
          product.toMap(),
        );

        // Save selected taxes
        if (product.productTaxes != null && product.productTaxes!.isNotEmpty) {
          for (final tax in product.productTaxes!) {
            await txn.insert(DatabaseHelper.tableProductTaxes, {
              'product_id': productId,
              'tax_rate_id': tax.taxRateId,
              'apply_order': tax.applyOrder,
            });
          }
        } else {
          // If no taxes selected, assign default tax
          final defaultTaxResult = await txn.query(
            DatabaseHelper.tableTaxRates,
            where: 'is_default = ? AND is_active = ?',
            whereArgs: [1, 1],
            limit: 1,
          );

          if (defaultTaxResult.isNotEmpty) {
            final defaultTaxId = defaultTaxResult.first['id'] as int;
            await txn.insert(DatabaseHelper.tableProductTaxes, {
              'product_id': productId,
              'tax_rate_id': defaultTaxId,
              'apply_order': 1,
            });
          }
        }

        // Save variants and Inventory
        if (product.variants != null && product.variants!.isNotEmpty) {
          for (final variant in product.variants!) {
            final variantModel = ProductVariantModel.fromEntity(variant);
            final variantMap = variantModel.toMap();
            variantMap['product_id'] = productId;
            variantMap.remove('id');

            final variantId = await txn.insert(
              DatabaseHelper.tableProductVariants,
              variantMap,
            );

            // --- INITIAL INVENTORY CREATION ---
            if (variant.stock != null && variant.stock! > 0) {
              // 1. Create Initial Lot
              await txn.insert(DatabaseHelper.tableInventoryLots, {
                'product_id': productId,
                'variant_id': variantId,
                'warehouse_id': defaultWarehouseId,
                'lot_number': 'Inicial',
                'quantity': variant.stock,
                'unit_cost_cents': variant.costPriceCents,
                'total_cost_cents': (variant.stock! * variant.costPriceCents)
                    .round(),
                'received_at': DateTime.now().toIso8601String(),
              });

              // 2. Create Inventory Summary
              await txn.insert(DatabaseHelper.tableInventory, {
                'product_id': productId,
                'warehouse_id': defaultWarehouseId,
                'variant_id': variantId,
                'quantity_on_hand': variant.stock,
                'quantity_reserved': 0,
                'updated_at': DateTime.now().toIso8601String(),
              });
            } else {
              // Verify if we should create empty inventory record?
              // Often useful to have 0 stock record instead of null.
              // But existing batch logic only does it if stock > 0.
              // I'll stick to batch logic for consistency.
              // Update: Actually, having a 0 record is good for "Out of Stock" vs "Not Carried".
              // But let's stick to the requested logic "utilizar la funcion usada en la creacion".
            }
          }
        }

        databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
        databaseHelper.notifyTableChanged(
          DatabaseHelper.tableInventory,
        ); // Notify inventory too
        return productId;
      });
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      final db = await databaseHelper.database;
      await db.transaction((txn) async {
        // Update product data
        await txn.update(
          DatabaseHelper.tableProducts,
          product.toMap(),
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

          final additionalBarcodes =
              variantMap.remove('additional_barcodes') as List<String>?;

          variantMap['product_id'] = product.id;

          int effectiveVariantId;
          if (variant.id != null && existingIds.contains(variant.id)) {
            // Update existing
            await txn.update(
              DatabaseHelper.tableProductVariants,
              variantMap,
              where: 'id = ?',
              whereArgs: [variant.id],
            );
            effectiveVariantId = variant.id!;
          } else {
            // Insert new (remove id to ensure autoincrement works if it was somehow set to 0 or null placeholder)
            variantMap.remove('id');
            effectiveVariantId = await txn.insert(
              DatabaseHelper.tableProductVariants,
              variantMap,
            );
          }

          // Handle Barcodes
          // Delete existing barcodes for this variant (smart update)
          await txn.delete(
            DatabaseHelper.tableProductBarcodes,
            where: 'variant_id = ?',
            whereArgs: [effectiveVariantId],
          );

          // Insert new barcodes
          if (additionalBarcodes != null) {
            for (final code in additionalBarcodes) {
              await txn.insert(DatabaseHelper.tableProductBarcodes, {
                'variant_id': effectiveVariantId,
                'barcode': code,
              });
            }
          }
        }
      });
      databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        DatabaseHelper.tableProducts,
        where: 'id = ?',
        whereArgs: [id],
      );
      databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addTaxToProduct(ProductTaxModel productTax) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(DatabaseHelper.tableProductTaxes, productTax.toMap());
      databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> removeTaxFromProduct(int productId, int taxRateId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        DatabaseHelper.tableProductTaxes,
        where: 'product_id = ? AND tax_rate_id = ?',
        whereArgs: [productId, taxRateId],
      );
      databaseHelper.notifyTableChanged(DatabaseHelper.tableProducts);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<ProductTaxModel>> getTaxesForProduct(int productId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableProductTaxes,
        where: 'product_id = ?',
        whereArgs: [productId],
      );
      return maps.map((map) => ProductTaxModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<TaxRateModel>> getTaxRatesForProduct(int productId) async {
    try {
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
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<int> saveVariant(ProductVariantModel variant) async {
    try {
      final db = await databaseHelper.database;
      final variantMap = variant.toMap();

      final additionalBarcodes =
          variantMap.remove('additional_barcodes') as List<String>?;

      variantMap.remove('id'); // Ensure ID is generated

      return await db.transaction((txn) async {
        final id = await txn.insert(
          DatabaseHelper.tableProductVariants,
          variantMap,
        );

        if (additionalBarcodes != null) {
          for (final code in additionalBarcodes) {
            await txn.insert(DatabaseHelper.tableProductBarcodes, {
              'variant_id': id,
              'barcode': code,
            });
          }
        }
        return id;
      });

      // Notify outside transaction or inside? notifyTableChanged isn't async on db operations usually
      // But we need to await transaction.
      // After transaction completes:
      // databaseHelper.notifyTableChanged(DatabaseHelper.tableProductVariants);
      // Wait, notifyTableChanged is on databaseHelper instance.
      // I'll keep it simple and notify after.
    } catch (e) {
      throw DatabaseException(e.toString());
    } finally {
      // Notify anyway or only on success? Usually on success.
      // Since I returned inside transaction, I should notify before return or execute transaction then notify.
      // Refactoring to standard pattern:
      databaseHelper.notifyTableChanged(DatabaseHelper.tableProductVariants);
    }
  }

  @override
  Future<void> updateVariant(ProductVariantModel variant) async {
    try {
      final db = await databaseHelper.database;
      final variantMap = variant.toMap();

      final additionalBarcodes =
          variantMap.remove('additional_barcodes') as List<String>?;

      await db.transaction((txn) async {
        await txn.update(
          DatabaseHelper.tableProductVariants,
          variantMap,
          where: 'id = ?',
          whereArgs: [variant.id],
        );

        // Update barcodes
        await txn.delete(
          DatabaseHelper.tableProductBarcodes,
          where: 'variant_id = ?',
          whereArgs: [variant.id],
        );

        if (additionalBarcodes != null) {
          for (final code in additionalBarcodes) {
            await txn.insert(DatabaseHelper.tableProductBarcodes, {
              'variant_id': variant.id,
              'barcode': code,
            });
          }
        }
      });
      databaseHelper.notifyTableChanged(DatabaseHelper.tableProductVariants);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<bool> isCodeUnique(String code, {int? excludeId}) async {
    try {
      final db = await databaseHelper.database;
      return DatabaseValidators.isFieldUnique(
        db: db,
        tableName: DatabaseHelper.tableProducts,
        fieldName: 'code',
        value: code,
        excludeId: excludeId,
      );
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<bool> isNameUnique(String name, {int? excludeId}) async {
    try {
      final db = await databaseHelper.database;
      return DatabaseValidators.isFieldUnique(
        db: db,
        tableName: DatabaseHelper.tableProducts,
        fieldName: 'name',
        value: name,
        excludeId: excludeId,
      );
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<bool> isBarcodeUnique(
    String barcode, {
    int? excludeId,
    int? excludeVariantId,
  }) async {
    try {
      final db = await databaseHelper.database;

      // Check if barcode exists in product_variants table
      final variantsResult = await db.query(
        DatabaseHelper.tableProductVariants,
        columns: ['id', 'product_id'],
        where: 'barcode = ?',
        whereArgs: [barcode],
      );

      // Check if barcode exists in product_barcodes table
      final additionalResult = await db.query(
        DatabaseHelper.tableProductBarcodes,
        columns: ['variant_id'],
        where: 'barcode = ?',
        whereArgs: [barcode],
      );

      // Join results logic
      // We need to check if ANY match conflicts with our exclude criteria.

      // 1. Check Product Variants Matches
      for (final match in variantsResult) {
        final matchVariantId = match['id'] as int;
        final matchProductId = match['product_id'] as int;

        if (excludeVariantId != null) {
          if (matchVariantId != excludeVariantId) return false;
        } else if (excludeId != null) {
          if (matchProductId != excludeId) return false;
        } else {
          return false; // Found match and no exclusions
        }
      }

      // 2. Check Additional Barcodes Matches
      for (final match in additionalResult) {
        final matchVariantId = match['variant_id'] as int;

        // Use a lightweight query to get product_id for this variant if excluding by product
        int? matchProductId;
        if (excludeId != null) {
          final pRes = await db.query(
            DatabaseHelper.tableProductVariants,
            columns: ['product_id'],
            where: 'id = ?',
            whereArgs: [matchVariantId],
          );
          if (pRes.isNotEmpty) matchProductId = pRes.first['product_id'] as int;
        }

        if (excludeVariantId != null) {
          if (matchVariantId != excludeVariantId) return false;
        } else if (excludeId != null && matchProductId != null) {
          if (matchProductId != excludeId) return false;
        } else {
          return false;
        }
      }

      return true; // No conflicts found
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<int> countProducts() async {
    try {
      final db = await databaseHelper.database;
      return Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${DatabaseHelper.tableProducts}',
            ),
          ) ??
          0;
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<Map<int, List<ProductVariantModel>>> _getVariantsForProducts(
    Database db,
    List<int> productIds,
  ) async {
    if (productIds.isEmpty) return {};

    // Get variants
    final variantMaps = await db.rawQuery('''
      SELECT pv.*, 
             (SELECT SUM(quantity) FROM ${DatabaseHelper.tableInventoryLots} WHERE variant_id = pv.id) as stock
      FROM ${DatabaseHelper.tableProductVariants} pv
      WHERE pv.product_id IN (${productIds.join(',')}) AND pv.is_active = 1
    ''');

    // Get variant IDs
    final variantIds = variantMaps.map((m) => m['id'] as int).toList();

    // Get additional barcodes
    Map<int, List<String>> barcodesByVariant = {};
    if (variantIds.isNotEmpty) {
      final barcodeMaps = await db.query(
        DatabaseHelper.tableProductBarcodes,
        columns: ['variant_id', 'barcode'],
        where: 'variant_id IN (${variantIds.join(',')})',
      );

      for (final bMap in barcodeMaps) {
        final vId = bMap['variant_id'] as int;
        barcodesByVariant.putIfAbsent(vId, () => []);
        barcodesByVariant[vId]!.add(bMap['barcode'] as String);
      }
    }

    // Group variants by product
    final variantsByProduct = <int, List<ProductVariantModel>>{};
    for (final variantMap in variantMaps) {
      final productId = variantMap['product_id'] as int;
      final variantId = variantMap['id'] as int;

      // Inject barcodes
      final modifiableMap = Map<String, dynamic>.from(variantMap);
      if (barcodesByVariant.containsKey(variantId)) {
        modifiableMap['additional_barcodes'] = barcodesByVariant[variantId];
      }

      variantsByProduct.putIfAbsent(productId, () => []);
      variantsByProduct[productId]!.add(
        ProductVariantModel.fromMap(modifiableMap),
      );
    }

    return variantsByProduct;
  }
}
