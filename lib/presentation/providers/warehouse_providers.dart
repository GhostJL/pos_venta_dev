import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/domain/use_cases/get_all_warehouses.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'warehouse_providers.g.dart';

@riverpod
class WarehouseNotifier extends _$WarehouseNotifier {
  
  // Helper method to read the use case provider
  GetAllWarehouses get _getAllWarehouses => ref.read(getAllWarehousesProvider);

  @override
  Future<List<Warehouse>> build() async {
    // The build method should return the initial list of warehouses.
    return _getAllWarehouses.call();
  }

  Future<void> addWarehouse(Warehouse warehouse) async {
    // Set the state to loading
    state = const AsyncValue.loading();
    // Use guard to handle potential errors
    state = await AsyncValue.guard(() async {
      await ref.read(createWarehouseProvider).call(warehouse);
      // After adding, refresh the list to get the updated data
      return _getAllWarehouses.call();
    });
  }

  Future<void> editWarehouse(Warehouse warehouse) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateWarehouseProvider).call(warehouse);
      return _getAllWarehouses.call();
    });
  }

  Future<void> removeWarehouse(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteWarehouseProvider).call(id);
      return _getAllWarehouses.call();
    });
  }
}
