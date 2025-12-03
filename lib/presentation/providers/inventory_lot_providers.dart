import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/inventory_lot_repository_impl.dart';
import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/domain/repositories/inventory_lot_repository.dart';

part 'inventory_lot_providers.g.dart';

// Repository Provider
@riverpod
InventoryLotRepository inventoryLotRepository(Ref ref) {
  return InventoryLotRepositoryImpl(DatabaseHelper.instance);
}

// Get lots by product and warehouse
@riverpod
Future<List<InventoryLot>> productLots(
  Ref ref,
  int productId,
  int warehouseId,
) async {
  final repository = ref.watch(inventoryLotRepositoryProvider);
  return repository.getLotsByProduct(productId, warehouseId);
}

// Get available lots (quantity > 0) by product and warehouse
@riverpod
Future<List<InventoryLot>> availableLots(
  Ref ref,
  int productId,
  int warehouseId,
) async {
  final repository = ref.watch(inventoryLotRepositoryProvider);
  return repository.getAvailableLots(productId, warehouseId);
}

// Get lot by ID
@riverpod
Future<InventoryLot?> lotById(Ref ref, int lotId) async {
  final repository = ref.watch(inventoryLotRepositoryProvider);
  return repository.getLotById(lotId);
}

// Get expiring lots for a warehouse
@riverpod
Future<List<InventoryLot>> expiringLots(
  Ref ref,
  int warehouseId,
  int withinDays,
) async {
  final repository = ref.watch(inventoryLotRepositoryProvider);
  return repository.getExpiringLots(warehouseId, withinDays);
}

// Get all lots for a warehouse
@riverpod
Future<List<InventoryLot>> warehouseLots(Ref ref, int warehouseId) async {
  final repository = ref.watch(inventoryLotRepositoryProvider);
  return repository.getLotsByWarehouse(warehouseId);
}
