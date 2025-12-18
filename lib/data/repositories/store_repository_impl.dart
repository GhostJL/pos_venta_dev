import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/datasources/database_constants.dart';
import 'package:posventa/data/models/store_model.dart';
import 'package:posventa/domain/entities/store.dart';
import 'package:posventa/domain/repositories/i_store_repository.dart';

class StoreRepositoryImpl implements IStoreRepository {
  final DatabaseHelper _databaseHelper;

  StoreRepositoryImpl({required DatabaseHelper databaseHelper})
    : _databaseHelper = databaseHelper;

  @override
  Future<Store?> getStore() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableStore,
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return StoreModel.fromJson(maps.first);
  }

  @override
  Future<void> updateStore(Store store) async {
    final db = await _databaseHelper.database;
    final model = StoreModel.fromEntity(store);

    await db.update(
      DatabaseConstants.tableStore,
      model.toJson(),
      where: 'id = ?',
      whereArgs: [store.id],
    );
  }
}
