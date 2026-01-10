import 'package:drift/drift.dart';

// =================================================================
// 1. SYSTEM AND USER TABLES
// =================================================================

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text().named('password_hash')();
  TextColumn get firstName => text().nullable().named('first_name')();
  TextColumn get lastName => text().nullable().named('last_name')();
  TextColumn get email => text().nullable()();
  TextColumn get role => text()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  BoolColumn get onboardingCompleted => boolean()
      .withDefault(const Constant(false))
      .named('onboarding_completed')();
  DateTimeColumn get lastLoginAt =>
      dateTime().nullable().named('last_login_at')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}

class Permissions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  TextColumn get description => text().nullable()();
  TextColumn get module => text()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
}

class UserPermissions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().named('user_id').references(Users, #id)();
  IntColumn get permissionId =>
      integer().named('permission_id').references(Permissions, #id)();
  DateTimeColumn get grantedAt => dateTime().named('granted_at')();
  IntColumn get grantedBy =>
      integer().nullable().named('granted_by').references(Users, #id)();

  @override
  String get tableName => 'user_permissions';
}

class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isRead =>
      boolean().withDefault(const Constant(false)).named('is_read')();
  TextColumn get type => text()();
  IntColumn get relatedProductId =>
      integer().nullable().named('related_product_id')();
  IntColumn get relatedVariantId =>
      integer().nullable().named('related_variant_id')();

  @override
  String get tableName => 'notifications';
}

class Stores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get businessName => text().nullable().named('business_name')();
  TextColumn get taxId => text().nullable().named('tax_id')();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get logoPath => text().nullable().named('logo_path')();
  TextColumn get receiptFooter => text().nullable().named('receipt_footer')();
  TextColumn get currency => text().withDefault(const Constant('MXN'))();
  TextColumn get timezone =>
      text().withDefault(const Constant('America/Mexico_City'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
}

class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
  @override
  String get tableName => 'app_meta';
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().nullable().references(Users, #id)();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
}

// =================================================================
// 2. CATALOG TABLES
// =================================================================

class Departments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  TextColumn get description => text().nullable()();
  IntColumn get displayOrder =>
      integer().withDefault(const Constant(0)).named('display_order')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  IntColumn get departmentId =>
      integer().named('department_id').references(Departments, #id)();
  IntColumn get parentCategoryId => integer()
      .nullable()
      .named('parent_category_id')
      .references(Categories, #id)();
  TextColumn get description => text().nullable()();
  IntColumn get displayOrder =>
      integer().withDefault(const Constant(0)).named('display_order')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
}

class Brands extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
}

class UnitsOfMeasure extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();

  @override
  String get tableName => 'units_of_measure';
}

class TaxRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  RealColumn get rate => real()();
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false)).named('is_default')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  BoolColumn get isEditable =>
      boolean().withDefault(const Constant(false)).named('is_editable')();
  BoolColumn get isOptional =>
      boolean().withDefault(const Constant(false)).named('is_optional')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();

  @override
  String get tableName => 'tax_rates';
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get departmentId =>
      integer().named('department_id').references(Departments, #id)();
  IntColumn get categoryId =>
      integer().named('category_id').references(Categories, #id)();
  IntColumn get brandId =>
      integer().nullable().named('brand_id').references(Brands, #id)();
  IntColumn get supplierId =>
      integer().nullable().named('supplier_id').references(Suppliers, #id)();
  BoolColumn get isSoldByWeight =>
      boolean().withDefault(const Constant(false)).named('is_sold_by_weight')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  BoolColumn get hasExpiration =>
      boolean().withDefault(const Constant(false)).named('has_expiration')();
  TextColumn get photoUrl => text().nullable().named('photo_url')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
}

class ProductVariants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()
      .named('product_id')
      .references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get variantName => text().named('variant_name')();
  TextColumn get barcode => text().nullable().unique()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  IntColumn get costPriceCents => integer().named('cost_price_cents')();
  IntColumn get salePriceCents => integer().named('sale_price_cents')();
  IntColumn get wholesalePriceCents =>
      integer().nullable().named('wholesale_price_cents')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  BoolColumn get isForSale =>
      boolean().withDefault(const Constant(true)).named('is_for_sale')();
  TextColumn get type => text().withDefault(const Constant('sales'))();
  IntColumn get linkedVariantId => integer()
      .nullable()
      .named('linked_variant_id')
      .references(ProductVariants, #id)();
  RealColumn get stockMin => real().nullable().named('stock_min')();
  RealColumn get stockMax => real().nullable().named('stock_max')();
  IntColumn get unitId => integer().nullable().named('unit_id')();
  BoolColumn get isSoldByWeight =>
      boolean().withDefault(const Constant(false)).named('is_sold_by_weight')();
  RealColumn get conversionFactor =>
      real().withDefault(const Constant(1.0)).named('conversion_factor')();
  TextColumn get photoUrl => text().nullable().named('photo_url')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();

  @override
  String get tableName => 'product_variants';
}

class ProductTaxes extends Table {
  IntColumn get productId => integer()
      .named('product_id')
      .references(Products, #id, onDelete: KeyAction.cascade)();
  IntColumn get taxRateId => integer()
      .named('tax_rate_id')
      .references(TaxRates, #id)(); // onDelete: Restrict is default or check
  IntColumn get applyOrder =>
      integer().withDefault(const Constant(1)).named('apply_order')();

  @override
  Set<Column> get primaryKey => {productId, taxRateId};
  @override
  String get tableName => 'product_taxes';
}

// =================================================================
// 3. INVENTORY TABLES
// =================================================================

class Warehouses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isMain =>
      boolean().withDefault(const Constant(false)).named('is_main')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
}

class Inventory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()
      .named('product_id')
      .references(Products, #id, onDelete: KeyAction.cascade)();
  IntColumn get warehouseId => integer()
      .named('warehouse_id')
      .references(Warehouses, #id, onDelete: KeyAction.cascade)();
  IntColumn get variantId => integer()
      .nullable()
      .named('variant_id')
      .references(ProductVariants, #id, onDelete: KeyAction.cascade)();
  RealColumn get quantityOnHand =>
      real().withDefault(const Constant(0.0)).named('quantity_on_hand')();
  RealColumn get quantityReserved =>
      real().withDefault(const Constant(0.0)).named('quantity_reserved')();
  IntColumn get minStock => integer().nullable().named('min_stock')();
  IntColumn get maxStock => integer().nullable().named('max_stock')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();

  @override
  List<String> get customConstraints => [
    'UNIQUE (product_id, warehouse_id, variant_id)',
  ];

  @override
  String get tableName => 'inventory';
}

class InventoryLots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()
      .named('product_id')
      .references(Products, #id, onDelete: KeyAction.cascade)();
  IntColumn get variantId => integer()
      .nullable()
      .named('variant_id')
      .references(ProductVariants, #id)();
  IntColumn get warehouseId => integer()
      .named('warehouse_id')
      .references(Warehouses, #id, onDelete: KeyAction.cascade)();
  TextColumn get lotNumber => text().named('lot_number')();
  RealColumn get quantity => real().withDefault(const Constant(0.0))();
  IntColumn get unitCostCents => integer().named('unit_cost_cents')();
  IntColumn get totalCostCents => integer().named('total_cost_cents')();
  DateTimeColumn get expirationDate =>
      dateTime().nullable().named('expiration_date')();
  DateTimeColumn get receivedAt =>
      dateTime().withDefault(currentDateAndTime).named('received_at')();

  @override
  String get tableName => 'inventory_lots';
}

class InventoryMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId =>
      integer().named('product_id').references(Products, #id)(); // Restrict
  IntColumn get warehouseId =>
      integer().named('warehouse_id').references(Warehouses, #id)(); // Restrict
  IntColumn get variantId => integer()
      .nullable()
      .named('variant_id')
      .references(ProductVariants, #id)();
  TextColumn get movementType => text().named('movement_type')();
  RealColumn get quantity => real()();
  RealColumn get quantityBefore => real().named('quantity_before')();
  RealColumn get quantityAfter => real().named('quantity_after')();
  TextColumn get referenceType => text().nullable().named('reference_type')();
  IntColumn get referenceId => integer().nullable().named('reference_id')();
  IntColumn get lotId =>
      integer().nullable().named('lot_id').references(InventoryLots, #id)();
  TextColumn get reason => text().nullable()();
  IntColumn get performedBy =>
      integer().named('performed_by').references(Users, #id)();
  DateTimeColumn get movementDate =>
      dateTime().withDefault(currentDateAndTime).named('movement_date')();

  @override
  String get tableName => 'inventory_movements';
}

// =================================================================
// 4. CASH MANAGEMENT TABLES
// =================================================================

class CashSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get warehouseId =>
      integer().named('warehouse_id').references(Warehouses, #id)();
  IntColumn get userId => integer().named('user_id').references(Users, #id)();
  IntColumn get openingBalanceCents =>
      integer().named('opening_balance_cents')();
  IntColumn get closingBalanceCents =>
      integer().nullable().named('closing_balance_cents')();
  IntColumn get expectedBalanceCents =>
      integer().nullable().named('expected_balance_cents')();
  IntColumn get differenceCents =>
      integer().nullable().named('difference_cents')();
  TextColumn get status => text().withDefault(const Constant('open'))();
  DateTimeColumn get openedAt =>
      dateTime().withDefault(currentDateAndTime).named('opened_at')();
  DateTimeColumn get closedAt => dateTime().nullable().named('closed_at')();

  @override
  String get tableName => 'cash_sessions';
}

class CashMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cashSessionId => integer()
      .named('cash_session_id')
      .references(CashSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get movementType =>
      text().named('movement_type')(); // 'entry' or 'withdrawal'
  IntColumn get amountCents => integer().named('amount_cents')();
  TextColumn get reason => text()();
  TextColumn get description => text().nullable()();
  IntColumn get performedBy =>
      integer().named('performed_by').references(Users, #id)();
  DateTimeColumn get movementDate =>
      dateTime().withDefault(currentDateAndTime).named('movement_date')();

  @override
  String get tableName => 'cash_movements';
}

// =================================================================
// 5. PARTY TABLES (Customers & Suppliers)
// =================================================================

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get firstName => text().named('first_name')();
  TextColumn get lastName => text().named('last_name')();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get taxId => text().nullable().named('tax_id')();
  TextColumn get businessName => text().nullable().named('business_name')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
}

class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  TextColumn get contactPerson => text().nullable().named('contact_person')();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get taxId => text().nullable().named('tax_id')();
  IntColumn get creditDays =>
      integer().withDefault(const Constant(0)).named('credit_days')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
}

// =================================================================
// 5. SALES TABLES
// =================================================================

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get saleNumber => text().unique().named('sale_number')();
  IntColumn get warehouseId =>
      integer().named('warehouse_id').references(Warehouses, #id)();
  IntColumn get customerId =>
      integer().nullable().named('customer_id').references(Customers, #id)();
  IntColumn get cashierId =>
      integer().named('cashier_id').references(Users, #id)();
  IntColumn get subtotalCents => integer().named('subtotal_cents')();
  IntColumn get discountCents =>
      integer().withDefault(const Constant(0)).named('discount_cents')();
  IntColumn get taxCents =>
      integer().withDefault(const Constant(0)).named('tax_cents')();
  IntColumn get totalCents => integer().named('total_cents')();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  DateTimeColumn get saleDate => dateTime().named('sale_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  IntColumn get cancelledBy =>
      integer().nullable().named('cancelled_by').references(Users, #id)();
  DateTimeColumn get cancelledAt =>
      dateTime().nullable().named('cancelled_at')();
  TextColumn get cancellationReason =>
      text().nullable().named('cancellation_reason')();
}

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer()
      .named('sale_id')
      .references(Sales, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId =>
      integer().named('product_id').references(Products, #id)();
  IntColumn get variantId => integer()
      .nullable()
      .named('variant_id')
      .references(ProductVariants, #id)();
  RealColumn get quantity => real()();
  TextColumn get unitOfMeasure => text().named('unit_of_measure')();
  IntColumn get unitPriceCents => integer().named('unit_price_cents')();
  IntColumn get discountCents =>
      integer().withDefault(const Constant(0)).named('discount_cents')();
  IntColumn get subtotalCents => integer().named('subtotal_cents')();
  IntColumn get taxCents =>
      integer().withDefault(const Constant(0)).named('tax_cents')();
  IntColumn get totalCents => integer().named('total_cents')();
  IntColumn get costPriceCents => integer().named('cost_price_cents')();
  IntColumn get lotId =>
      integer().nullable().named('lot_id').references(InventoryLots, #id)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();

  @override
  String get tableName => 'sale_items';
}

class SaleItemTaxes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleItemId => integer()
      .named('sale_item_id')
      .references(SaleItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get taxRateId =>
      integer().named('tax_rate_id').references(TaxRates, #id)();
  TextColumn get taxName => text().named('tax_name')();
  RealColumn get taxRate => real().named('tax_rate')();
  IntColumn get taxAmountCents => integer().named('tax_amount_cents')();

  @override
  String get tableName => 'sale_item_taxes';
}

class SalePayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer()
      .named('sale_id')
      .references(Sales, #id, onDelete: KeyAction.cascade)();
  TextColumn get paymentMethod => text().named('payment_method')();
  IntColumn get amountCents => integer().named('amount_cents')();
  TextColumn get referenceNumber =>
      text().nullable().named('reference_number')();
  DateTimeColumn get paymentDate =>
      dateTime().withDefault(currentDateAndTime).named('payment_date')();
  IntColumn get receivedBy =>
      integer().named('received_by').references(Users, #id)();

  @override
  String get tableName => 'sale_payments';
}

class SaleReturns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get returnNumber => text().unique().named('return_number')();
  IntColumn get saleId => integer().named('sale_id').references(Sales, #id)();
  IntColumn get warehouseId =>
      integer().named('warehouse_id').references(Warehouses, #id)();
  IntColumn get customerId =>
      integer().nullable().named('customer_id').references(Customers, #id)();
  IntColumn get processedBy =>
      integer().named('processed_by').references(Users, #id)();
  IntColumn get subtotalCents => integer().named('subtotal_cents')();
  IntColumn get taxCents =>
      integer().withDefault(const Constant(0)).named('tax_cents')();
  IntColumn get totalCents => integer().named('total_cents')();
  TextColumn get refundMethod => text().named('refund_method')();
  TextColumn get reason => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  DateTimeColumn get returnDate => dateTime().named('return_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();

  @override
  String get tableName => 'sale_returns';
}

class SaleReturnItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleReturnId => integer()
      .named('sale_return_id')
      .references(SaleReturns, #id, onDelete: KeyAction.cascade)();
  IntColumn get saleItemId =>
      integer().named('sale_item_id').references(SaleItems, #id)();
  IntColumn get productId =>
      integer().named('product_id').references(Products, #id)();
  RealColumn get quantity => real()();
  IntColumn get unitPriceCents => integer().named('unit_price_cents')();
  IntColumn get subtotalCents => integer().named('subtotal_cents')();
  IntColumn get taxCents =>
      integer().withDefault(const Constant(0)).named('tax_cents')();
  IntColumn get totalCents => integer().named('total_cents')();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();

  @override
  String get tableName => 'sale_return_items';
}

class SaleItemLots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleItemId => integer()
      .named('sale_item_id')
      .references(SaleItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get lotId =>
      integer().named('lot_id').references(InventoryLots, #id)();
  RealColumn get quantityDeducted => real().named('quantity_deducted')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();

  @override
  String get tableName => 'sale_item_lots';
}

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().nullable().named(
    'user_id',
  )(); // No reference constraint to simplify for now or add if needed
  TextColumn get action => text()();
  TextColumn get module => text()();
  TextColumn get details => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();

  @override
  String get tableName => 'audit_logs';
}

// =================================================================
// 6. PURCHASE TABLES
// =================================================================

class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get purchaseNumber => text().unique().named('purchase_number')();
  IntColumn get supplierId =>
      integer().named('supplier_id').references(Suppliers, #id)();
  IntColumn get warehouseId =>
      integer().named('warehouse_id').references(Warehouses, #id)();
  IntColumn get subtotalCents => integer().named('subtotal_cents')();
  IntColumn get taxCents =>
      integer().withDefault(const Constant(0)).named('tax_cents')();
  IntColumn get totalCents => integer().named('total_cents')();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get purchaseDate => dateTime().named('purchase_date')();
  DateTimeColumn get receivedDate =>
      dateTime().nullable().named('received_date')();
  TextColumn get supplierInvoiceNumber =>
      text().nullable().named('supplier_invoice_number')();
  @ReferenceName('requestedPurchases')
  IntColumn get requestedBy =>
      integer().named('requested_by').references(Users, #id)();
  @ReferenceName('receivedPurchases')
  IntColumn get receivedBy =>
      integer().nullable().named('received_by').references(Users, #id)();
  @ReferenceName('cancelledPurchases')
  IntColumn get cancelledBy =>
      integer().nullable().named('cancelled_by').references(Users, #id)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
}

class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId => integer()
      .named('purchase_id')
      .references(Purchases, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId =>
      integer().named('product_id').references(Products, #id)();
  IntColumn get variantId => integer()
      .nullable()
      .named('variant_id')
      .references(ProductVariants, #id)();
  RealColumn get quantity => real()();
  RealColumn get quantityReceived =>
      real().withDefault(const Constant(0)).named('quantity_received')();
  TextColumn get unitOfMeasure => text().named('unit_of_measure')();
  IntColumn get unitCostCents => integer().named('unit_cost_cents')();
  IntColumn get subtotalCents => integer().named('subtotal_cents')();
  IntColumn get taxCents =>
      integer().withDefault(const Constant(0)).named('tax_cents')();
  IntColumn get totalCents => integer().named('total_cents')();
  IntColumn get lotId =>
      integer().nullable().named('lot_id').references(InventoryLots, #id)();
  DateTimeColumn get expirationDate =>
      dateTime().nullable().named('expiration_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();

  @override
  String get tableName => 'purchase_items';
}
