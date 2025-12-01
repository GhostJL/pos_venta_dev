import 'package:posventa/domain/entities/unit_of_measure.dart';

class UnitOfMeasureModel extends UnitOfMeasure {
  const UnitOfMeasureModel({
    super.id,
    required super.code,
    required super.name,
  });

  factory UnitOfMeasureModel.fromEntity(UnitOfMeasure unit) {
    return UnitOfMeasureModel(id: unit.id, code: unit.code, name: unit.name);
  }

  factory UnitOfMeasureModel.fromMap(Map<String, dynamic> map) {
    return UnitOfMeasureModel(
      id: map['id'],
      code: map['code'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'name': name};
  }
}
