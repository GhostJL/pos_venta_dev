import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/unit_of_measure_model.dart';
import 'package:posventa/domain/entities/unit_of_measure.dart';
import 'package:posventa/domain/repositories/unit_of_measure_repository.dart';

class UnitOfMeasureRepositoryImpl implements UnitOfMeasureRepository {
  final drift_db.AppDatabase db;

  UnitOfMeasureRepositoryImpl(this.db);

  @override
  Future<List<UnitOfMeasure>> getAllUnits() async {
    final rows = await db.select(db.unitsOfMeasure).get();
    return rows
        .map(
          (row) =>
              UnitOfMeasureModel(id: row.id, name: row.name, code: row.code),
        )
        .toList();
  }

  @override
  Future<UnitOfMeasure?> getUnitById(int id) async {
    final row = await (db.select(
      db.unitsOfMeasure,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return UnitOfMeasureModel(id: row.id, name: row.name, code: row.code);
    }
    return null;
  }
}
