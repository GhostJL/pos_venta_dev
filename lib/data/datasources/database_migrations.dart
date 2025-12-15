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
