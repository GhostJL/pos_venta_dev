import 'package:posventa/domain/entities/unit_of_measure.dart';
import 'package:posventa/domain/repositories/unit_of_measure_repository.dart';

class GetUnitsOfMeasureUseCase {
  final UnitOfMeasureRepository _repository;

  GetUnitsOfMeasureUseCase(this._repository);

  Future<List<UnitOfMeasure>> call() {
    return _repository.getAllUnits();
  }
}
