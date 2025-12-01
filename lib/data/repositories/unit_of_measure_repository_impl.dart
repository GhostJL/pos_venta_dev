import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/unit_of_measure_model.dart';
import 'package:posventa/domain/entities/unit_of_measure.dart';
import 'package:posventa/domain/repositories/unit_of_measure_repository.dart';

class UnitOfMeasureRepositoryImpl implements UnitOfMeasureRepository {
  final DatabaseHelper databaseHelper;

  UnitOfMeasureRepositoryImpl(this.databaseHelper);

  @override
  Future<List<UnitOfMeasure>> getAllUnits() async {
    final db = await databaseHelper.database;
    final maps = await db.query(DatabaseHelper.tableUnitsOfMeasure);
    return maps.map((map) => UnitOfMeasureModel.fromMap(map)).toList();
  }

  @override
  Future<UnitOfMeasure?> getUnitById(int id) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableUnitsOfMeasure,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UnitOfMeasureModel.fromMap(maps.first);
    }
    return null;
  }
}
