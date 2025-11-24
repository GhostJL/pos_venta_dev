import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/warehouse_repository_impl.dart';
import 'package:posventa/domain/repositories/warehouse_repository.dart';
import 'package:posventa/domain/use_cases/warehouse/create_warehouse.dart';
import 'package:posventa/domain/use_cases/warehouse/delete_warehouse.dart';
import 'package:posventa/domain/use_cases/warehouse/get_all_warehouses.dart';
import 'package:posventa/domain/use_cases/warehouse/update_warehouse.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';
import 'package:posventa/data/repositories/inventory_repository_impl.dart';
import 'package:posventa/domain/use_cases/inventory/get_all_inventory.dart';
import 'package:posventa/domain/use_cases/inventory/create_inventory.dart';
import 'package:posventa/domain/use_cases/inventory/update_inventory.dart';
import 'package:posventa/domain/use_cases/inventory/delete_inventory.dart';
import 'package:posventa/domain/use_cases/inventory/get_inventory_by_product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';
import 'package:posventa/data/repositories/product_repository_impl.dart';
import 'package:posventa/domain/use_cases/product/get_all_products.dart';
import 'package:posventa/domain/use_cases/product/create_product.dart';
import 'package:posventa/domain/use_cases/product/update_product.dart';
import 'package:posventa/domain/use_cases/product/delete_product.dart';
import 'package:posventa/domain/use_cases/product/search_products.dart';
import 'package:posventa/domain/repositories/inventory_movement_repository.dart';
import 'package:posventa/data/repositories/inventory_movement_repository_impl.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_all_inventory_movements.dart';
import 'package:posventa/domain/use_cases/inventory_movement/create_inventory_movement.dart';
import 'package:posventa/domain/use_cases/inventory_movement/update_inventory_movement.dart';
import 'package:posventa/domain/use_cases/inventory_movement/delete_inventory_movement.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_inventory_movements_by_product.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_inventory_movements_by_warehouse.dart';
import 'package:posventa/domain/use_cases/inventory_movement/get_inventory_movements_by_date_range.dart';
import 'package:posventa/domain/repositories/user_repository.dart';
import 'package:posventa/data/repositories/auth_repository_impl.dart';
import 'package:posventa/domain/use_cases/user/get_all_users.dart';
import 'package:posventa/domain/use_cases/user/create_user.dart';
import 'package:posventa/domain/use_cases/user/update_user.dart';
import 'package:posventa/domain/use_cases/user/delete_user.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';
import 'package:posventa/data/repositories/customer_repository_impl.dart';
import 'package:posventa/domain/use_cases/customer/get_customers_use_case.dart';
import 'package:posventa/domain/use_cases/customer/create_customer_use_case.dart';
import 'package:posventa/domain/use_cases/customer/update_customer_use_case.dart';
import 'package:posventa/domain/use_cases/customer/delete_customer_use_case.dart';
import 'package:posventa/domain/use_cases/customer/search_customers_use_case.dart';
import 'package:posventa/domain/use_cases/customer/generate_next_customer_code_use_case.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';
import 'package:posventa/data/repositories/sale_repository_impl.dart';
import 'package:posventa/domain/use_cases/sale/create_sale_use_case.dart';
import 'package:posventa/domain/use_cases/sale/get_sales_use_case.dart';
import 'package:posventa/domain/use_cases/sale/get_sale_by_id_use_case.dart';
import 'package:posventa/domain/use_cases/sale/generate_next_sale_number_use_case.dart';
import 'package:posventa/domain/use_cases/sale/cancel_sale_use_case.dart';
import 'package:posventa/domain/repositories/cash_session_repository.dart';
import 'package:posventa/data/repositories/cash_session_repository_impl.dart';
import 'package:posventa/domain/use_cases/cash_movement/get_current_session.dart';
import 'package:posventa/domain/use_cases/cash_session/open_cash_session_use_case.dart';
import 'package:posventa/domain/use_cases/cash_session/close_cash_session_use_case.dart';
import 'package:posventa/domain/use_cases/cash_session/get_current_cash_session_use_case.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';
import 'package:posventa/data/repositories/purchase_repository_impl.dart';
import 'package:posventa/domain/use_cases/purchase/get_purchases_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/get_purchase_by_id_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/create_purchase_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/update_purchase_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/delete_purchase_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/receive_purchase_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/cancel_purchase_usecase.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';
import 'package:posventa/data/repositories/purchase_item_repository_impl.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_items_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_items_by_purchase_id_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_item_by_id_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_items_by_product_id_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/create_purchase_item_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/update_purchase_item_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/delete_purchase_item_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_items_by_date_range_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_recent_purchase_items_usecase.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/domain/use_cases/inventory/adjust_inventory_use_case.dart';
import 'package:posventa/domain/use_cases/inventory/adjust_inventory_batch_use_case.dart';
import 'package:posventa/domain/use_cases/inventory/transfer_inventory_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
DatabaseHelper databaseHelper(ref) => DatabaseHelper.instance;

@riverpod
WarehouseRepository warehouseRepository(ref) =>
    WarehouseRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllWarehouses getAllWarehouses(ref) =>
    GetAllWarehouses(ref.watch(warehouseRepositoryProvider));

@riverpod
CreateWarehouse createWarehouse(ref) =>
    CreateWarehouse(ref.watch(warehouseRepositoryProvider));

@riverpod
UpdateWarehouse updateWarehouse(ref) =>
    UpdateWarehouse(ref.watch(warehouseRepositoryProvider));

@riverpod
DeleteWarehouse deleteWarehouse(ref) =>
    DeleteWarehouse(ref.watch(warehouseRepositoryProvider));

// Inventory Providers
@riverpod
InventoryRepository inventoryRepository(ref) =>
    InventoryRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllInventory getAllInventory(ref) =>
    GetAllInventory(ref.watch(inventoryRepositoryProvider));

@riverpod
CreateInventory createInventory(ref) =>
    CreateInventory(ref.watch(inventoryRepositoryProvider));

@riverpod
UpdateInventory updateInventory(ref) =>
    UpdateInventory(ref.watch(inventoryRepositoryProvider));

@riverpod
DeleteInventory deleteInventory(ref) =>
    DeleteInventory(ref.watch(inventoryRepositoryProvider));

@riverpod
GetInventoryByProduct getInventoryByProduct(ref) =>
    GetInventoryByProduct(ref.watch(inventoryRepositoryProvider));

// Product Providers
@riverpod
ProductRepository productRepository(ref) =>
    ProductRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllProducts getAllProducts(ref) =>
    GetAllProducts(ref.watch(productRepositoryProvider));

@riverpod
CreateProduct createProduct(ref) =>
    CreateProduct(ref.watch(productRepositoryProvider));

@riverpod
UpdateProduct updateProduct(ref) =>
    UpdateProduct(ref.watch(productRepositoryProvider));

@riverpod
DeleteProduct deleteProduct(ref) =>
    DeleteProduct(ref.watch(productRepositoryProvider));

@riverpod
SearchProducts searchProducts(ref) =>
    SearchProducts(ref.watch(productRepositoryProvider));

// Inventory Movement Providers
@riverpod
InventoryMovementRepository inventoryMovementRepository(ref) =>
    InventoryMovementRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllInventoryMovements getAllInventoryMovements(ref) =>
    GetAllInventoryMovements(ref.watch(inventoryMovementRepositoryProvider));

@riverpod
CreateInventoryMovement createInventoryMovement(ref) =>
    CreateInventoryMovement(ref.watch(inventoryMovementRepositoryProvider));

@riverpod
UpdateInventoryMovement updateInventoryMovement(ref) =>
    UpdateInventoryMovement(ref.watch(inventoryMovementRepositoryProvider));

@riverpod
DeleteInventoryMovement deleteInventoryMovement(ref) =>
    DeleteInventoryMovement(ref.watch(inventoryMovementRepositoryProvider));

@riverpod
GetInventoryMovementsByProduct getInventoryMovementsByProduct(ref) =>
    GetInventoryMovementsByProduct(
      ref.watch(inventoryMovementRepositoryProvider),
    );

@riverpod
GetInventoryMovementsByWarehouse getInventoryMovementsByWarehouse(ref) =>
    GetInventoryMovementsByWarehouse(
      ref.watch(inventoryMovementRepositoryProvider),
    );

@riverpod
GetInventoryMovementsByDateRange getInventoryMovementsByDateRange(ref) =>
    GetInventoryMovementsByDateRange(
      ref.watch(inventoryMovementRepositoryProvider),
    );

// User Providers
@riverpod
UserRepository userRepository(ref) =>
    AuthRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllUsers getAllUsers(ref) => GetAllUsers(ref.watch(userRepositoryProvider));

@riverpod
CreateUser createUser(ref) => CreateUser(ref.watch(userRepositoryProvider));

@riverpod
UpdateUser updateUser(ref) => UpdateUser(ref.watch(userRepositoryProvider));

@riverpod
DeleteUser deleteUser(ref) => DeleteUser(ref.watch(userRepositoryProvider));

// Customer Providers
@riverpod
CustomerRepository customerRepository(ref) =>
    CustomerRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetCustomersUseCase getCustomersUseCase(ref) =>
    GetCustomersUseCase(ref.watch(customerRepositoryProvider));

@riverpod
CreateCustomerUseCase createCustomerUseCase(ref) =>
    CreateCustomerUseCase(ref.watch(customerRepositoryProvider));

@riverpod
UpdateCustomerUseCase updateCustomerUseCase(ref) =>
    UpdateCustomerUseCase(ref.watch(customerRepositoryProvider));

@riverpod
DeleteCustomerUseCase deleteCustomerUseCase(ref) =>
    DeleteCustomerUseCase(ref.watch(customerRepositoryProvider));

@riverpod
SearchCustomersUseCase searchCustomersUseCase(ref) =>
    SearchCustomersUseCase(ref.watch(customerRepositoryProvider));

@riverpod
GenerateNextCustomerCodeUseCase generateNextCustomerCodeUseCase(ref) =>
    GenerateNextCustomerCodeUseCase(ref.watch(customerRepositoryProvider));

// --- Sale Providers ---

@riverpod
SaleRepository saleRepository(ref) =>
    SaleRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
CreateSaleUseCase createSaleUseCase(ref) =>
    CreateSaleUseCase(ref.watch(saleRepositoryProvider));

@riverpod
GetSalesUseCase getSalesUseCase(ref) =>
    GetSalesUseCase(ref.watch(saleRepositoryProvider));

@riverpod
GetSaleByIdUseCase getSaleByIdUseCase(ref) =>
    GetSaleByIdUseCase(ref.watch(saleRepositoryProvider));

@riverpod
GenerateNextSaleNumberUseCase generateNextSaleNumberUseCase(ref) =>
    GenerateNextSaleNumberUseCase(ref.watch(saleRepositoryProvider));

@riverpod
CancelSaleUseCase cancelSaleUseCase(ref) =>
    CancelSaleUseCase(ref.watch(saleRepositoryProvider));

// --- Cash Session Providers ---

@riverpod
CashSessionRepository cashSessionRepository(ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  if (user == null) {
    throw Exception('User not authenticated');
  }
  return CashSessionRepositoryImpl(ref.watch(databaseHelperProvider), user.id!);
}

@riverpod
GetCurrentSession getCurrentSession(ref) =>
    GetCurrentSession(ref.watch(cashSessionRepositoryProvider));

@riverpod
GetCurrentCashSessionUseCase getCurrentCashSessionUseCase(ref) =>
    GetCurrentCashSessionUseCase(ref.watch(cashSessionRepositoryProvider));

@riverpod
OpenCashSessionUseCase openCashSessionUseCase(ref) =>
    OpenCashSessionUseCase(ref.watch(cashSessionRepositoryProvider));

@riverpod
CloseCashSessionUseCase closeCashSessionUseCase(ref) =>
    CloseCashSessionUseCase(ref.watch(cashSessionRepositoryProvider));

@riverpod
Future<dynamic> currentCashSession(ref) async {
  return await ref.watch(getCurrentCashSessionUseCaseProvider).call();
}

// --- Purchase Providers ---

@riverpod
PurchaseRepository purchaseRepository(ref) =>
    PurchaseRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetPurchasesUseCase getPurchasesUseCase(ref) =>
    GetPurchasesUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
GetPurchaseByIdUseCase getPurchaseByIdUseCase(ref) =>
    GetPurchaseByIdUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
CreatePurchaseUseCase createPurchaseUseCase(ref) =>
    CreatePurchaseUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
UpdatePurchaseUseCase updatePurchaseUseCase(ref) =>
    UpdatePurchaseUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
DeletePurchaseUseCase deletePurchaseUseCase(ref) =>
    DeletePurchaseUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
ReceivePurchaseUseCase receivePurchaseUseCase(ref) =>
    ReceivePurchaseUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
CancelPurchaseUseCase cancelPurchaseUseCase(ref) =>
    CancelPurchaseUseCase(ref.watch(purchaseRepositoryProvider));

// --- Purchase Item Providers ---

@riverpod
PurchaseItemRepository purchaseItemRepository(ref) =>
    PurchaseItemRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetPurchaseItemsUseCase getPurchaseItemsUseCase(ref) =>
    GetPurchaseItemsUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
GetPurchaseItemsByPurchaseIdUseCase getPurchaseItemsByPurchaseIdUseCase(ref) =>
    GetPurchaseItemsByPurchaseIdUseCase(
      ref.watch(purchaseItemRepositoryProvider),
    );

@riverpod
GetPurchaseItemByIdUseCase getPurchaseItemByIdUseCase(ref) =>
    GetPurchaseItemByIdUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
GetPurchaseItemsByProductIdUseCase getPurchaseItemsByProductIdUseCase(ref) =>
    GetPurchaseItemsByProductIdUseCase(
      ref.watch(purchaseItemRepositoryProvider),
    );

@riverpod
CreatePurchaseItemUseCase createPurchaseItemUseCase(ref) =>
    CreatePurchaseItemUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
UpdatePurchaseItemUseCase updatePurchaseItemUseCase(ref) =>
    UpdatePurchaseItemUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
DeletePurchaseItemUseCase deletePurchaseItemUseCase(ref) =>
    DeletePurchaseItemUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
GetPurchaseItemsByDateRangeUseCase getPurchaseItemsByDateRangeUseCase(ref) =>
    GetPurchaseItemsByDateRangeUseCase(
      ref.watch(purchaseItemRepositoryProvider),
    );

@riverpod
GetRecentPurchaseItemsUseCase getRecentPurchaseItemsUseCase(ref) =>
    GetRecentPurchaseItemsUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
AdjustInventoryUseCase adjustInventory(ref) {
  return AdjustInventoryUseCase(ref.watch(inventoryRepositoryProvider));
}

@riverpod
TransferInventoryUseCase transferInventory(ref) {
  return TransferInventoryUseCase(ref.watch(inventoryRepositoryProvider));
}

@riverpod
AdjustInventoryBatchUseCase adjustInventoryBatchUseCase(ref) {
  return AdjustInventoryBatchUseCase(ref.watch(inventoryRepositoryProvider));
}
