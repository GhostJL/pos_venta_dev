import 'package:sqflite/sqflite.dart';
import 'database_constants.dart';

class DatabaseMigrations {
  static Future<void> processMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration from version 21 to 22: Add inventory_lots table and update schema
    if (oldVersion < 22 && newVersion >= 22) {
      await _migrateToVersion22(db);
    }

    // Migration from version 22 to 23: Add sale_item_lots table for lot tracking
    if (oldVersion < 23 && newVersion >= 23) {
      await _migrateToVersion23(db);
    }
    // Migration from version 23 to 24: Add Sales/Purchase variant separation
    if (oldVersion < 24 && newVersion >= 24) {
      await _migrateToVersion24(db);
    }
    // Migration from version 24 to 25: Add variant_id to inventory table for independent variant stock
    if (oldVersion < 25 && newVersion >= 25) {
      await _migrateToVersion25(db);
    }
    // Migration from version 25 to 26: Add conversion_factor to product_variants
    if (oldVersion < 26 && newVersion >= 26) {
      await _migrateToVersion26(db);
    }
    // Migration from version 26 to 27: Add has_expiration to products
    if (oldVersion < 27 && newVersion >= 27) {
      await _migrateToVersion27(db);
    }

    // Migration from version 27 to 28: Add stock_min/max to product_variants
    if (oldVersion < 28 && newVersion >= 28) {
      await _migrateToVersion28(db);
    }
    // Migration from version 28 to 29: Add is_sold_by_weight to products and unit_id/is_sold_by_weight to product_variants
    if (oldVersion < 29 && newVersion >= 29) {
      await _migrateToVersion29(db);
    }
  }

  static Future<void> _migrateToVersion29(Database db) async {
    // Add is_sold_by_weight to products
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableProducts}
        ADD COLUMN is_sold_by_weight INTEGER NOT NULL DEFAULT 0 CHECK (is_sold_by_weight IN (0,1));
      ''');
    } catch (e) {
      // Column might already exist
    }

    // Add unit_id to product_variants
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableProductVariants}
        ADD COLUMN unit_id INTEGER REFERENCES ${DatabaseConstants.tableUnitsOfMeasure}(id) ON DELETE RESTRICT;
      ''');
    } catch (e) {
      // Column might already exist
    }

    // Add is_sold_by_weight to product_variants
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableProductVariants}
        ADD COLUMN is_sold_by_weight INTEGER NOT NULL DEFAULT 0 CHECK (is_sold_by_weight IN (0,1));
      ''');
    } catch (e) {
      // Column might already exist
    }
  }

  static Future<void> _migrateToVersion27(Database db) async {
    // Add has_expiration column to products
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableProducts}
        ADD COLUMN has_expiration INTEGER NOT NULL DEFAULT 0 CHECK (has_expiration IN (0,1));
      ''');
    } catch (e) {
      // Column might already exist
    }
  }

  static Future<void> _migrateToVersion28(Database db) async {
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableProductVariants}
        ADD COLUMN stock_min REAL;
      ''');
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableProductVariants}
        ADD COLUMN stock_max REAL;
      ''');
    } catch (e) {
      // Columns might already exist
    }
  }

  static Future<void> _migrateToVersion26(Database db) async {
    // Add conversion_factor column to product_variants
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableProductVariants}
        ADD COLUMN conversion_factor REAL DEFAULT 1.0;
      ''');
    } catch (e) {
      // Column might already exist
    }
  }

  static Future<void> _migrateToVersion25(Database db) async {
    // 1. Add variant_id to inventory table
    // We need to recreate the table because we are changing the UNIQUE constraint
    await _recreateInventoryTableV25(db);

    // 2. Add variant_id to inventory_movements if it doesn't exist
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableInventoryMovements}
        ADD COLUMN variant_id INTEGER REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE SET NULL;
      ''');
    } catch (e) {
      // Column might already exist
    }
  }

  static Future<void> _recreateInventoryTableV25(Database db) async {
    // Create temporary table with new schema including variant_id in UNIQUE constraint
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableInventory}_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        warehouse_id INTEGER NOT NULL,
        variant_id INTEGER,
        quantity_on_hand REAL NOT NULL DEFAULT 0,
        quantity_reserved REAL NOT NULL DEFAULT 0,
        min_stock INTEGER,
        max_stock INTEGER,
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        UNIQUE (product_id, warehouse_id, variant_id),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE CASCADE,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE CASCADE,
        FOREIGN KEY (variant_id) REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE CASCADE
      )
    ''');

    // Copy data from old table.
    // NOTE: Existing inventory is assumed to be for the base product (variant_id = NULL)
    await db.execute('''
      INSERT INTO ${DatabaseConstants.tableInventory}_new 
        (id, product_id, warehouse_id, quantity_on_hand, quantity_reserved, min_stock, max_stock, updated_at)
      SELECT id, product_id, warehouse_id, quantity_on_hand, quantity_reserved, min_stock, max_stock, updated_at
      FROM ${DatabaseConstants.tableInventory}
    ''');

    // Drop old table
    await db.execute('DROP TABLE ${DatabaseConstants.tableInventory}');

    // Rename new table to original name
    await db.execute('''
      ALTER TABLE ${DatabaseConstants.tableInventory}_new 
      RENAME TO ${DatabaseConstants.tableInventory}
    ''');

    // Recreate indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_product 
      ON ${DatabaseConstants.tableInventory}(product_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_warehouse 
      ON ${DatabaseConstants.tableInventory}(warehouse_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_variant
      ON ${DatabaseConstants.tableInventory}(variant_id)
    ''');
  }

  static Future<void> _migrateToVersion24(Database db) async {
    // Add type column to product_variants
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableProductVariants}
        ADD COLUMN type TEXT DEFAULT 'sales';
      ''');
    } catch (e) {
      // Column might already exist
    }

    // Add linked_variant_id column to product_variants
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableProductVariants}
        ADD COLUMN linked_variant_id INTEGER REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE SET NULL;
      ''');
    } catch (e) {
      // Column might already exist
    }
  }

  static Future<void> _migrateToVersion22(Database db) async {
    // Create inventory_lots table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableInventoryLots} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        variant_id INTEGER,
        warehouse_id INTEGER NOT NULL,
        lot_number TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 0,
        unit_cost_cents INTEGER NOT NULL,
        total_cost_cents INTEGER NOT NULL,
        expiration_date TEXT,
        received_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE CASCADE,
        FOREIGN KEY (variant_id) REFERENCES ${DatabaseConstants.tableProductVariants}(id) ON DELETE SET NULL,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for inventory_lots
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_lots_product 
      ON ${DatabaseConstants.tableInventoryLots}(product_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_lots_warehouse 
      ON ${DatabaseConstants.tableInventoryLots}(warehouse_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_lots_number 
      ON ${DatabaseConstants.tableInventoryLots}(lot_number)
    ''');

    // Add lot_id column to inventory_movements if it doesn't exist
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableInventoryMovements}
        ADD COLUMN lot_id INTEGER REFERENCES ${DatabaseConstants.tableInventoryLots}(id) ON DELETE SET NULL
      ''');
    } catch (e) {
      // Column might already exist, ignore error
    }

    // Add lot_id column to purchase_items if it doesn't exist
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tablePurchaseItems}
        ADD COLUMN lot_id INTEGER REFERENCES ${DatabaseConstants.tableInventoryLots}(id) ON DELETE SET NULL
      ''');
    } catch (e) {
      // Column might already exist, ignore error
    }

    // Add lot_id column to sale_items if it doesn't exist
    try {
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.tableSaleItems}
        ADD COLUMN lot_id INTEGER REFERENCES ${DatabaseConstants.tableInventoryLots}(id) ON DELETE SET NULL
      ''');
    } catch (e) {
      // Column might already exist, ignore error
    }

    // Remove lot_number and expiration_date from inventory table
    // SQLite doesn't support DROP COLUMN, so we need to recreate the table
    await _recreateInventoryTable(db);
  }

  static Future<void> _recreateInventoryTable(Database db) async {
    // Create temporary table with new schema
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableInventory}_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        warehouse_id INTEGER NOT NULL,
        quantity_on_hand REAL NOT NULL DEFAULT 0,
        quantity_reserved REAL NOT NULL DEFAULT 0,
        min_stock INTEGER,
        max_stock INTEGER,
        updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        UNIQUE (product_id, warehouse_id),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseConstants.tableProducts}(id) ON DELETE CASCADE,
        FOREIGN KEY (warehouse_id) REFERENCES ${DatabaseConstants.tableWarehouses}(id) ON DELETE CASCADE
      )
    ''');

    // Copy data from old table to new table (excluding lot_number and expiration_date)
    await db.execute('''
      INSERT INTO ${DatabaseConstants.tableInventory}_new 
        (id, product_id, warehouse_id, quantity_on_hand, quantity_reserved, min_stock, max_stock, updated_at)
      SELECT id, product_id, warehouse_id, quantity_on_hand, quantity_reserved, min_stock, max_stock, updated_at
      FROM ${DatabaseConstants.tableInventory}
    ''');

    // Drop old table
    await db.execute('DROP TABLE ${DatabaseConstants.tableInventory}');

    // Rename new table to original name
    await db.execute('''
      ALTER TABLE ${DatabaseConstants.tableInventory}_new 
      RENAME TO ${DatabaseConstants.tableInventory}
    ''');

    // Recreate indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_product 
      ON ${DatabaseConstants.tableInventory}(product_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_warehouse 
      ON ${DatabaseConstants.tableInventory}(warehouse_id)
    ''');
  }

  static Future<void> _migrateToVersion23(Database db) async {
    // Create sale_item_lots table to track lot deductions per sale item
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableSaleItemLots} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_item_id INTEGER NOT NULL,
        lot_id INTEGER NOT NULL,
        quantity_deducted REAL NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (sale_item_id) REFERENCES ${DatabaseConstants.tableSaleItems}(id) ON DELETE CASCADE,
        FOREIGN KEY (lot_id) REFERENCES ${DatabaseConstants.tableInventoryLots}(id) ON DELETE RESTRICT
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sale_item_lots_sale_item 
      ON ${DatabaseConstants.tableSaleItemLots}(sale_item_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sale_item_lots_lot 
      ON ${DatabaseConstants.tableSaleItemLots}(lot_id)
    ''');
  }
}
