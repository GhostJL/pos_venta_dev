import 'package:posventa/domain/entities/store.dart';

abstract class IStoreRepository {
  Future<Store?> getStore();
  Future<void> updateStore(Store store);
}
