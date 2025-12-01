import 'package:posventa/domain/entities/unit_of_measure.dart';

abstract class UnitOfMeasureRepository {
  Future<List<UnitOfMeasure>> getAllUnits();
  Future<UnitOfMeasure?> getUnitById(int id);
}
